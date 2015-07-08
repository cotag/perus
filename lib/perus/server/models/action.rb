module Perus::Server
    class Action < Sequel::Model
        plugin :validation_helpers
        plugin :serialization

        many_to_one :system
        many_to_one :command_config
        many_to_one :script
        
        serialize_attributes :json, :file

        def config_hash
            if command_config_id
                command_config.config_hash
            else
                script.config_hash
            end
        end

        def command_name
            if script_id
                script.name
            else
                command_config.command
            end
        end

        def options
            if script_id
                {}
            else
                command_config.options
            end
        end

        def validate
            super
            validates_presence :system_id
        end

        def after_destroy
            super
            if command_config_id
                command_config.destroy
            end
        end
    end
end
