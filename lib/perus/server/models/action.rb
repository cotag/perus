module Perus::Server
    class Action < Sequel::Model
        plugin :validation_helpers
        plugin :serialization
        many_to_one :system
        
        serialize_attributes :json, :file
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
            validates_presence [:system_id, :command]
        end
    end
end
