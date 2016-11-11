require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'json'
require 'uri'

module Perus::Server
    class App < Sinatra::Application
        #----------------------
        # config
        #----------------------
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
        admin :group
        admin :alert
        admin :config, true
        admin :script, true

        # static admin index page
        get '/admin' do
            redirect "#{url_prefix}admin/systems"
        end

        post '/admin/scripts/:id/commands' do
            protected!
            script = Script.with_pk!(params['id'])
            script_command = ScriptCommand.new
            script_command.script_id = params['id']
            script_command.order = script.largest_order + 1

            command_config = CommandConfig.create_with_params(params)
            script_command.command_config_id = command_config.id

            begin
                script_command.save
            rescue
                if script_command.command_config_id
                    CommandConfig.with_pk!(script_command.command_config_id).destroy
                end
            end

            redirect "#{url_prefix}admin/scripts/#{params['id']}"
        end

        post '/admin/scripts/:script_id/commands/:id' do
            protected!
            script_command = ScriptCommand.with_pk!(params['id'])
            if params['action'] == 'Delete'
                script_command.destroy
            elsif params['action'] == 'Update'
                script_command.command_config.update_options!(params)
            end

            redirect "#{url_prefix}admin/scripts/#{params['script_id']}"
        end

        post '/admin/configs/:id/metrics' do
            protected!
            config = Config.with_pk!(params['id'])
            config_metric = ConfigMetric.new
            config_metric.config_id = params['id']
            config_metric.order = config.largest_order + 1

            command_config = CommandConfig.create_with_params(params)
            config_metric.command_config_id = command_config.id

            begin
                config_metric.save
            rescue
                if config_metric.command_config_id
                    CommandConfig.with_pk!(config_metric.command_config_id).destroy
                end
            end

            redirect "#{url_prefix}admin/configs/#{params['id']}"
        end

        post '/admin/configs/:config_id/metrics/:id' do
            protected!
            config_metric = ConfigMetric.with_pk!(params['id'])
            if params['action'] == 'Delete'
                config_metric.destroy
            elsif params['action'] == 'Update'
                config_metric.command_config.update_options!(params)
            end

            redirect "#{url_prefix}admin/configs/#{params['config_id']}"
        end

        get '/admin/stats' do
            protected!
            @stats = Stats.new
            @queue_length = Server.ping_queue.length
            erb :stats
        end


        #----------------------
        # API
        #----------------------
        # csv for graphs shown on system page
        get '/systems/:id/values' do
            protected!
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
            ping_params = params.dup

            system_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.ip

            Server.ping_queue << Proc.new do
                # update the system with its last known ip and update time
                system = System.with_pk!(ping_params['id'])
                system.last_updated = timestamp
                system.ip = system_ip
                system.save

                # errors is either nil or a hash of the format - module: [err, ...]
                system.save_metric_errors(ping_params, timestamp)

                # add each new value, a later process cleans up old values
                system.save_values(ping_params, timestamp)

                # save action return values and prevent them from running again
                system.save_actions(ping_params, timestamp)
            end

            content_type :json
            {success: true}.to_json
        end

        # system config
        get '/systems/:id/config' do
            system = System.with_pk!(params['id'])
            content_type :json
            system.config_hash.to_json
        end

        # config of system based on request ip
        get '/systems/config_for_ip' do
            ip = request.env['HTTP_X_FORWARDED_FOR'] || request.ip
            begin
                system = System.where(ip: ip).first
                content_type :json
                system.config_hash.to_json
            rescue => e
                STDERR.puts "\nNo config for: #{ip}\n"
                raise e
            end
        end

        # render all errors in html to replace the shortened subset on the system page
        get '/systems/:id/errors' do
            protected!
            system = System.with_pk!(params['id'])
            errors = system.collection_errors
            erb :errors, layout: false, locals: {errors: errors}
        end

        # clear collection errors
        delete '/systems/:id/errors' do
            protected!
            system = System.with_pk!(params['id'])
            system.collection_errors.each(&:delete)
            redirect "#{url_prefix}systems/#{system.id}"
        end

        # create a new action
        post '/systems/:id/actions' do
            protected!
            Action.add(params['id'], params)
            redirect "#{url_prefix}systems/#{params['id']}#actions"
        end

        # create an action for all systems in a group
        post '/groups/:id/systems/actions' do
            protected!
            group = Group.with_pk!(params['id'])
            group.systems.each do |system|
                Action.add(system.id, params)
            end

            redirect "#{url_prefix}groups/#{params['id']}/systems"
        end

        # delete completed actions in a group
        delete '/groups/:id/systems/actions' do
            protected!
            group = Group.with_pk!(params['id'])
            group.systems.each do |system|
                system.actions.each do |action|
                    next if action.timestamp.nil?
                    action.destroy
                end
            end

            redirect "#{url_prefix}groups/#{params['id']}/systems"
        end

        # create an action for all systems
        post '/systems/actions' do
            protected!
            System.each do |system|
                Action.add(system.id, params)
            end

            redirect "#{url_prefix}systems"
        end

        # delete all completed actions
        delete '/systems/actions' do
            protected!
            Action.each do |action|
                next if action.timestamp.nil?
                action.destroy
            end

            redirect "#{url_prefix}systems"
        end

        # delete an action. deletion also clears any uploaded files.
        delete '/systems/:system_id/actions/:id' do
            protected!
            action = Action.with_pk!(params['id'])
            action.destroy
            redirect "#{url_prefix}systems/#{params['system_id']}#actions"
        end


        #----------------------
        # frontend
        #----------------------
        # overview
        get '/' do
            protected!
            systems = System.all
            @alerts = Alert.all.sort_by(&:severity_level).reverse
            erb :index
        end

        # list of systems
        get '/systems' do
            protected!
            @systems = System.all.group_by(&:orientation)
            @title = 'All Systems'
            @scripts = Script.all
            @action_url = "systems/actions"
            erb :systems
        end

        # list of systems by group
        get '/groups/:id/systems' do
            protected!
            group = Group.with_pk!(params['id'])
            @systems = group.systems_dataset.order_by(:name).all.group_by(&:orientation)
            @title = group.name
            @scripts = Script.all
            @action_url = "groups/#{params['id']}/systems/actions"
            erb :systems
        end

        # info page for a system
        get '/systems/:id' do
            protected!
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
            URI::extract(@links).each {|uri| @links.gsub!(uri, %Q{<a href="#{uri}" target="_new">#{uri}</a>})}

            # last updated is a timestamp, conver
            if @system.last_updated
                @last_updated = Time.at(@system.last_updated).ctime
            else
                @last_updated = 'never updated'
            end

            @errors = @system.collection_errors_dataset.limit(5).all
            @total_error_count = @system.collection_errors_dataset.count
            @scripts = Script.all
            erb :system
        end

        # helper to make uploads publicly accessible
        get '/uploads/*' do
            protected!
            path = params['splat'][0]
            raise 'Invalid path' if path.include?('..')
            full_path = File.join(Server.options.uploads_dir, path)
            send_file full_path
        end
    end
end
