require 'sequel'

module Server::DB
    def self.start
        # connect/create the database and run any new migrations
        Sequel.extension :migration
        Sequel::Model.plugin :crushyform
        @db = Sequel.sqlite(Server::Options.db_path)
        Sequel::Migrator.run(@db, File.join(__dir__, 'migrations'))

        # load models - these rely on an existing db connection
        require File.join(__dir__, 'models', 'system')
        require File.join(__dir__, 'models', 'config')
        require File.join(__dir__, 'models', 'value')
        require File.join(__dir__, 'models', 'group')
    end
end
