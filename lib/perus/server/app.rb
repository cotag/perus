require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/reloader'
require 'sequel'
require 'json'
require 'uri'

module Perus::Server
    class App < Sinatra::Application
        #----------------------
        # config
        #----------------------
        register Sinatra::Synchrony
        helpers Helpers

        configure do
            set :root, File.join(__dir__)
        end

        configure :development do
            register Sinatra::Reloader
        end

        before do
            load_site_information
        end


        #----------------------
        # admin pages
        #----------------------
        extend Admin

        admin :system
        admin :config
        admin :group
        admin :alert

        # static admin index page
        get '/admin' do
            redirect '/admin/systems'
        end


        #----------------------
        # API
        #----------------------
        # csv for graphs shown on system page
        get '/systems/:id/values' do
            system  = System.with_pk!(params['id'])
            metrics = params[:metrics].to_s.split(',')

            # find all values for the requested metrics
            dataset = system.values_dataset.where(metric: metrics)

            # the graphing library requires multiple series to be provided in
            # row format (date, series 1, series 2 etc) so each value is
            # grouped into a timestamp update window
            updates = dataset.all.group_by(&:timestamp)

            # loop from start to end generating the response csv
            timestamps = updates.keys.sort
            csv = "Date,#{params['metrics']}\n"

            timestamps.each do |timestamp|
                date = Time.at(timestamp).strftime('%Y-%m-%d %H:%M:%S')
                csv << date << ','
                
                values = Array.new(metrics.length)
                records = updates[timestamp]

                records.each do |record|
                    values[metrics.index(record.metric)] = record.num_value
                end

                csv << values.join(',') << "\n"
            end

            csv
        end

        # receive data from a client
        post '/systems/:id/ping' do
            timestamp = Time.now.to_i

            # update the system with its last known ip and update time
            system = System.with_pk!(params['id'])
            system.last_updated = timestamp
            system.ip = request.ip

            # errors is either nil or a hash of the format - module: [err, ...]
            system.save_metric_errors(params, timestamp)

            # add each new value, a later process cleans up old values
            system.save_values(params, timestamp)

            # save action return values and prevent them from running again
            system.save_actions(params, timestamp)

            # ip, last updated, uploads and metrics are now updated. these are
            # stored on the system.
            system.save
            content_type :json
            {success: true}.to_json
        end

        # system config
        get '/systems/:id/config' do
            system = System.with_pk!(params['id'])
            config = system.config.config
            actions = system.actions_dataset.where(timestamp: nil).all
            config['actions'] = actions.map(&:config_hash)
            content_type :json
            config.to_json
        end

        # clear collection errors
        delete '/systems/:id/errors' do
            system = System.with_pk!(params['id'])
            system.collection_errors.each(&:delete)
            redirect "/systems/#{system.id}"
        end

        # create a new action
        post '/systems/:id/actions' do
            action = Action.new
            action.system_id = params['id']
            action.command = params['command']

            if params['options']
                action.options = params['options'].reject do |attr, value|
                    value.empty?
                end
            else
                action.options = {}
            end

            begin
                action.save
            rescue
            end

            redirect "/systems/#{params['id']}"
        end

        # delete an action. deletion also clears any uploaded files.
        delete '/systems/:system_id/actions/:id' do
            action = Action.with_pk!(params['id'])
            action.destroy
            redirect "/systems/#{params['system_id']}"
        end


        #----------------------
        # frontend
        #----------------------
        # overview
        get '/' do
            systems = System.all
            alerts = Alert.all
            results = alerts.collect do |alert|
                begin
                    alert.execute(systems)
                rescue => e
                    "An error occurred running this alert: #{e.inspect}"
                end
            end

            @alerts = Hash[alerts.zip(results)]
            erb :index
        end

        # list of systems
        get '/systems' do
            @systems = System.all.group_by(&:orientation)
            @title = 'All Systems'
            erb :systems
        end

        # list of systems by group
        get '/groups/:id/systems' do
            group = Group.with_pk!(params['id'])
            @systems = group.systems.group_by(&:orientation)
            @title = group.name
            erb :systems
        end

        # info page for a system
        get '/systems/:id' do
            @system  = System.with_pk!(params['id'])
            @uploads = @system.upload_urls
            metrics = @system.metrics

            # we're only interested in the latest value for string metrics
            @str_metrics = {}
            metrics.select(&:string?).each do |metric|
                value = @system.latest(metric.name)
                name = "#{metric.name.titlecase}:"
                @str_metrics[name] = value ? value.str_value : ''
            end

            # numeric values are grouped together by their first name component
            # and drawn on a graph. e.g cpu_all and cpu_chrome are shown together
            num_metrics = metrics.select(&:numeric?).map(&:name)
            @num_metrics = num_metrics.group_by {|n| n.split('_')[0]}

            # make links clickable
            @links = @system.links.to_s.gsub("\n", "<br>")
            URI::extract(@links).each {|uri| @links.gsub!(uri, %Q{<a href="#{uri}">#{uri}</a>})}

            # last updated is a timestamp, conver
            if @system.last_updated
                @last_updated = Time.at(@system.last_updated).ctime
            else
                @last_updated = 'never updated'
            end

            # collect command names for creating actions
            @commands = Perus::Pinger::Command.subclasses.reject(&:metric?)
            @commands.reject!(&:abstract?)
            erb :system
        end

        # helper to make uploads publicly accessible
        get '/uploads/*' do
            path = params['splat'][0]
            raise 'Invalid path' if path.include?('..')
            full_path = File.join(Server.options.uploads_dir, path)
            send_file full_path
        end
    end
end
