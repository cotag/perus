module Perus::Server
    class Script < Sequel::Model
        plugin :validation_helpers
        one_to_many :script_commands, order: :order
        one_to_many :actions

        def code_name
            name.gsub(' ', '_').camelize
        end

        def config_hash
            {
                id: id,
                type: 'Script',
                options: {
                    commands: script_commands.collect(&:config_hash)
                }
            }
        end

        def largest_order
            if script_commands.empty?
                0
            else
                script_commands.last.order
            end
        end

        def can_delete?
            actions_dataset.empty?
        end

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end

        def after_destroy
            super
            script_commands.each(&:destroy)
        end
    end
end
