module Perus::Server
    class ScriptCommand < Sequel::Model
        many_to_one :script
        many_to_one :command_config

        def config_hash
            command_config.config_hash
        end

        def after_destroy
            super
            command_config.destroy
        end
    end
end
