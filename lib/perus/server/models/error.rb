class Server::Error < Sequel::Model
    many_to_one :system
end
