require 'sequel'
require 'sequel/plugins/serialization'
require './options'

module Perus
    module Server
        # enable string extensions
        Sequel.extension :migration
        Sequel.extension :inflector

        # options file
        DEFAULT_OPTIONS_PATH = '/etc/perus-server'

        require './server/helpers'
        require './server/form'
        require './server/admin'
        require './server/app'
        require './server/db'
        require './server/server'
    end

    Server::Server.new.run if __FILE__ == $0
end
