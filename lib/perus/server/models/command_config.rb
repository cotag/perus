module Perus::Server
    class CommandConfig < Sequel::Model
        plugin :serialization
        serialize_attributes :json, :options

        def config_hash
            {
                id: id,
                type: command,
                options: options
            }
        end

        def validate
            super
            validates_presence :command
        end
    end
end
