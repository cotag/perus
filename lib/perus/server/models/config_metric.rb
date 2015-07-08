module Perus::Server
    class ConfigMetric < Sequel::Model
        many_to_one :config
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
