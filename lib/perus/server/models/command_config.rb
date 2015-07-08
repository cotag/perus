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

        def command_class
            Perus::Pinger.const_get(command)
        end

        def update_options!(params)
            self.options = self.class.process_options(params)
            save
        end

        def self.process_options(params)
            return {} if params['options'].nil?

            # ignore empty options (will use default)
            options = params['options'].reject do |attr, value|
                value.empty?
            end

            # replace 'true' and 'false' with actual boolean values
            # but only for boolean options
            command = Perus::Pinger.const_get(params['command'])
            command.options.each do |option|
                next unless option.boolean?
                next unless options.include?(option.name.to_s)
                value = options[option.name.to_s]
                options[option.name.to_s] = value == 'true'
            end

            options
        end

        def self.create_with_params(params)
            options = process_options(params)
            CommandConfig.create(
                command: params['command'],
                options: options
            )
        end
    end
end
