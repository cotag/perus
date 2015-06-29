module Server
    require './server/options'
    require './server/form'
    require './server/admin'
    require './server/app'
    require './server/db'
    require './server/instance'
end

Server::Instance.run if __FILE__ == $0
