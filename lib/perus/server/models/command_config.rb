module Perus::Server
    class CommandConfig < Sequel::Model
        plugin :validation_helpers
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

        def self.create_with_params(params)
            if params['options']
                options = params['options'].reject do |attr, value|
                    value.empty?
                end
            else
                options = {}
            end

            CommandConfig.create(
                command: params['command'],
                options: options
            )
        end
    end
end
