require 'sequel'
require 'sequel/plugins/serialization'

module Perus::Server
    module DB
        def self.start
            Sequel.extension :migration
            Sequel.extension :inflector

            # connect/create the database and run any new migrations
            @db = Sequel.sqlite(Server.options.db_path, integer_booleans: true)
            Sequel::Migrator.run(@db, File.join(__dir__, 'migrations'))

            # load models - these rely on an existing db connection
            require File.join(__dir__, 'models', 'system')
            require File.join(__dir__, 'models', 'config')
            require File.join(__dir__, 'models', 'value')
            require File.join(__dir__, 'models', 'group')
            require File.join(__dir__, 'models', 'error')
            require File.join(__dir__, 'models', 'alert')
            require File.join(__dir__, 'models', 'action')
            require File.join(__dir__, 'models', 'metric')
            require File.join(__dir__, 'models', 'script')
            require File.join(__dir__, 'models', 'command_config')
            require File.join(__dir__, 'models', 'script_command')
            require File.join(__dir__, 'models', 'config_metric')
        end
    end
end
