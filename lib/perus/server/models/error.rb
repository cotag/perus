module Perus::Server
    class Error < Sequel::Model
        many_to_one :system
    end
end
