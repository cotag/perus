module Server
    require './server/config'
    require './server/app'
    require './server/db'
    require './server/instance'
end

Server::Instance.run if __FILE__ == $0
