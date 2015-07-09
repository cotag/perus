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
                hash = command_config.config_hash
            else
                hash = script.config_hash
            end

            # replace the command config/script id with the action's id
            hash['id'] = id
            hash
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

        def file_name
            file['original_name']
        end

        def file_url
            prefix = URI(Server.options.uploads_url)
            path = File.join(system_id.to_s, file['filename'])
            (prefix + path).to_s
        end

        def file_path
            File.join(system.uploads_dir, file['filename'])
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

            if file
                File.unlink(file_path)
            end
        end
    end
end
