module Perus::Server
    class ScriptCommand < Sequel::Model
        many_to_one :script
        one_to_one  :command_config

        def config_hash
            command_config.config_hash
        end
    end
end
