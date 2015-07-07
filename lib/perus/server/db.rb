require 'sequel'
require 'sequel/plugins/serialization'

module Perus::Server
    module DB
        def self.start
            # connect/create the database and run any new migrations
            Sequel.extension :migration
            @db = Sequel.sqlite(Server.options.db_path)
            Sequel::Migrator.run(@db, File.join(__dir__, 'migrations'))

            # load models - these rely on an existing db connection
            require File.join(__dir__, 'models', 'system')
            require File.join(__dir__, 'models', 'config')
            require File.join(__dir__, 'models', 'value')
            require File.join(__dir__, 'models', 'group')
            require File.join(__dir__, 'models', 'error')
            require File.join(__dir__, 'models', 'alert')
        end
    end
end
