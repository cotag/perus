require 'sequel'
require 'sequel/plugins/serialization'
require 'concurrent'

module Perus::Server
    module DB
        def self.db
            @db
        end

        def self.start
            puts 'Loading database'
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

            # attempt to run vacuum twice a day. this is done to increase
            # performance rather than reclaim unused space. as old values and
            # metrics are deleted the data become very fragmented. vacuuming
            # restructures the db so system records in the values index should
            # be sequentially stored
            vacuum_task = Concurrent::TimerTask.new do
                @db.execute('vacuum')
            end

            # fire every 12 hours
            vacuum_task.execution_interval = 60 * 60 * 12
            vacuum_task.execute

            # a fixed number of hours of data are kept in the database. once an
            # hour, old values and files are removed. if all values of a metric
            # are removed from a system, the accompanying metric record is also
            # removed.
            cleanup_task = Concurrent::TimerTask.new do
                Perus::Server::DB.cleanup
            end

            # fire every hour
            cleanup_task.execution_interval = 60 * 60
            cleanup_task.execute
        end

        def self.cleanup
            puts 'Cleaning old values and metrics'
            keep_hours = Server.options.keep_hours

            # remove old values
            min_timestamp = Time.now.to_i - (keep_hours * 60)
            values = Value.where("timestamp < #{min_timestamp}")
            puts "Deleting #{values.count} values"
            values.each(&:destroy)

            # remove metrics from systems if they no longer have any values
            empty_deleted = 0
            file_deleted = 0

            Metric.each do |metric|
                if metric.file
                    path = metric.path
                    if !File.exists?(path) || File.mtime(path).to_i < min_timestamp
                        metric.destroy
                        file_deleted += 1
                    end
                elsif metric.values_dataset.empty?
                    metric.destroy
                    empty_deleted += 1
                end
            end

            puts "#{empty_deleted} metrics were deleted as they had no values"
            puts "#{file_deleted} metrics were deleted as they had old files"
        end
    end
end
