require 'sinatra'
require 'ostruct'
require 'sequel'
require 'json'
require 'yaml'

module Config
    def self.screenshots_dir
        './screenshots'
    end

    def self.data_dir
        './data'
    end

    def self.db_path
        './perus.db'
    end
end

# static index page
get '/' do
end

# info page for a system
get '/systems/:id' do
end

# receive data from a system
post '/ping' do
    ip = request.ip

    File.open(File.join(Config.screenshots_dir, "#{ip}.jpg"), 'wb') do |f|
        f.write params[:screenshot][:tempfile].read
    end

    File.open(File.join(Config.data_dir, "#{ip}.json"), 'w') do |f|
        f.write params[:data]
    end

    content_type :json
    {success: true}.to_json
end

# static admin index page
get '/admin' do
end

# list of systems
get '/admin/systems' do
end

# create a system
post '/admin/systems' do
end

# view a system
get '/admin/systems/:id'

# update a system
put '/admin/systems/:id' do
end

# delete a system
delete '/admin/systems/:id' do
end
