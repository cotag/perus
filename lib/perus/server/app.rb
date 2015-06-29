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

        configure do
            set :root, File.join(__dir__)
        end

        configure :development do
            register Sinatra::Reloader
        end

        before do
            @site_name = Server::Options.site_name
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
        # static index page
        get '/' do
            erb :index
        end

        # info page for a system
        get '/systems/:id' do
        end

        # receive data from a system
        post '/ping' do
            ip = request.ip

            File.open(File.join(Options.screenshots_dir, "#{ip}.jpg"), 'wb') do |f|
                f.write params[:screenshot][:tempfile].read
            end

            File.open(File.join(Options.data_dir, "#{ip}.json"), 'w') do |f|
                f.write params[:data]
            end

            content_type :json
            {success: true}.to_json
        end
    end
end
