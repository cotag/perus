require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/reloader'
require 'sequel'
require 'json'
require 'uri'

module Server
    class App < Sinatra::Application
        #----------------------
        # config
        #----------------------
        register Sinatra::Synchrony
        helpers Server::Helpers

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
        extend Server::Admin

        admin :system
        admin :config
        admin :group
        admin :alert

        # static admin index page
        get '/admin' do
            redirect '/admin/systems'
        end


        #----------------------
        # frontend
        #----------------------
        # overview
        get '/' do
            systems = Server::System.all
            alerts = Server::Alert.all
            @alerts = Hash[alerts.zip(alerts.collect {|alert| alert.execute(systems)})]
            erb :index
        end

        # list of systems
        get '/systems' do
            @systems = Server::System.all.group_by(&:orientation)
            @title = 'All Systems'
            erb :systems
        end

        # list of systems by group
        get '/groups/:id/systems' do
            group = Server::Group.with_pk!(params['id'])
            @systems = group.systems.group_by(&:orientation)
            @title = group.name
            erb :systems
        end

        # info page for a system
        get '/systems/:id' do
            @system  = Server::System.with_pk!(params['id'])
            @uploads = @system.upload_urls

            # we're only interested in the latest value for string metrics
            @str_metrics = {}
            str_metrics = @system.metrics['str'] || []
            dataset = @system.values_dataset
            str_metrics.each do |name|
                value = @system.latest(name)
                name = "#{name.titlecase}:"
                @str_metrics[name] = value ? value.str_value : ''
            end

            # numeric values are grouped together by their first name component
            # and drawn on a graph. e.g cpu_all and cpu_chrome are shown together
            num_metrics = @system.metrics['num'] || []
            @num_metrics = num_metrics.group_by {|n| n.split('_')[0]}

            # make links clickable
            @links = @system.links.gsub("\n", "<br>")
            URI::extract(@links).each {|uri| @links.gsub!(uri, %Q{<a href="#{uri}">#{uri}</a>})}

            # last updated is a timestamp, conver
            @last_updated = Time.at(@system.last_updated).ctime
            erb :system
        end

        get '/systems/:id/values' do
            system  = Server::System.with_pk!(params['id'])
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

        # receive data from a system
        post '/systems/:id/ping' do
            # values are sent as a json object
            values = JSON.parse(params[:values])
            timestamp = Time.now.to_i

            # update the system with its last known ip and update time
            system = Server::System.with_pk!(params['id'])
            system.last_updated = timestamp
            system.ip = request.ip

            # errors is either nil or a hash of the format - module: [err, ...]
            errors = values.delete('errors')
            if errors
                errors.each do |name, module_errors|
                    module_errors.each do |error|
                        Server::Error.create(
                            system_id: system.id,
                            timestamp: timestamp,
                            module: name,
                            description: error
                        )
                    end
                end
            end

            # the system object stores files on disk and updates an 'uploads'
            # field with a list of filenames and mimetypes
            uploads = values.delete('uploads')
            system.save_uploads(uploads, params) if uploads

            # add each new value, a later process cleans up old values
            system.save_values(values, timestamp)

            # ip, last updated, uploads and metrics are now updated. these are
            # stored on the system.
            system.save
            content_type :json
            {success: true}.to_json
        end

        # system config
        get '/systems/:id/config' do
            system = Server::System.with_pk!(params['id'])
            content_type :json
            system.config.config
        end

        # clear collection errors
        delete '/systems/:id/errors' do
            system = Server::System.with_pk!(params['id'])
            system.collection_errors.each(&:delete)
            redirect "/systems/#{system.id}"
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
