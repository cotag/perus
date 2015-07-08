module Perus::Server
    class Action < Sequel::Model
        plugin :validation_helpers
        plugin :serialization

        many_to_one :system
        one_to_one  :command_config
        one_to_one  :script
        
        serialize_attributes :json, :file

        def config_hash
            if command_config_id
                command_config.config_hash
            else
                script.config_hash
            end
        end

        def validate
            super
            validates_presence :system_id
        end
    end
end
