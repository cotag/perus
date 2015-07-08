module Perus::Server
    class ConfigMetric < Sequel::Model
        many_to_one :config
        one_to_one  :command_config

        def config_hash
            command_config.config_hash
        end
    end
end
