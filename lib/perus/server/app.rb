require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/reloader'
require 'sequel'
require 'json'

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

        # static admin index page
        get '/admin' do
            redirect '/admin/systems'
        end


        #----------------------
        # frontend
        #----------------------
        # overview
        get '/' do
            erb :index
        end

        # list of systems
        get '/systems' do
            @systems = Server::System.all
            @title = 'All Systems'
            erb :systems
        end

        # list of systems by group
        get '/groups/:id/systems' do
            group = Server::Group.with_pk!(params['id'])
            @systems = group.systems
            @title = "#{group.name} Systems"
            erb :systems
        end

        # info page for a system
        get '/systems/:id' do
            @system  = Server::System.with_pk!(params['id'])
            @metrics = @system.values.group_by(&:metric)
            @uploads = @system.upload_urls
            erb :system
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

            # the system object stores files on disk and updates an 'uploads'
            # field with a list of filenames and mimetypes
            uploads = values.delete('uploads')
            system.save_uploads(uploads, params) if uploads

            # ip, last updated and uploads are the only fields modified on the
            # system during a ping so we can save changes now
            system.save
            
            # TODO: handle errors
            values.delete('errors')

            # add each new value, a later process cleans up old values
            values.each do |(name, value)|
                attrs = {
                    system_id: system.id,
                    timestamp: timestamp,
                    metric: name
                }

                if value.kind_of?(Numeric)
                    attrs[:num_value] = value
                else
                    attrs[:str_value] = value
                end

                Value.create(attrs)
            end

            content_type :json
            {success: true}.to_json
        end

        # system config
        get '/systems/:id/config' do
            system = Server::System.with_pk!(params['id'])
            content_type :json
            system.config.config
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
