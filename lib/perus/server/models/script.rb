module Perus::Server
    class Script < Sequel::Model
        plugin :validation_helpers
        one_to_many :script_commands, order: 'name asc'

        def code_name
            name.gsub(' ', '_').camelize
        end

        def config_hashes
            script_commands.collect(&:config_hash)
        end

        def largest_order
            if script_commands.empty?
                0
            else
                script_commands.last.order
            end
        end

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end
    end
end
