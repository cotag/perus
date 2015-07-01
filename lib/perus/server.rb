require './options'

module Server
    require './server/helpers'
    require './server/form'
    require './server/admin'
    require './server/app'
    require './server/db'
    require './server/instance'

    # options
    def self.options
        @options ||= Perus::Options.new
    end
end

if __FILE__ == $0
    Server::Instance.run
else
    Server::Instance.init
end
