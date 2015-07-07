require './options'

module Perus
    module Server
        require './server/helpers'
        require './server/form'
        require './server/admin'
        require './server/app'
        require './server/db'
        require './server/server'

        # options file
        DEFAULT_OPTIONS_PATH = '/etc/perus-server'
    end

    Server::Server.new.run if __FILE__ == $0
end
