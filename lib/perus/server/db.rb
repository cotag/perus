require 'sequel'
require 'sequel/plugins/serialization'
require 'concurrent'

module Perus::Server
    module DB
        MAX_VACUUM_ATTEMPTS = 5
        MAX_CLEAN_ATTEMPTS = 5

        def self.db
            @db
        end

        def self.start
            puts 'Loading database'
            Sequel.extension :migration
            Sequel.extension :inflector

            # connect/create the database and run any new migrations
            @db = Sequel.postgres((Server.options.db['db'] || 'perus'), host: (Server.options.db['host'] || ENV['POSTGRES_HOST'] || 'localhost'), username: Server.options.db['username'], password: Server.options.db['password'])
            Sequel::Migrator.run(@db, File.join(__dir__, 'migrations'))

            # load models - these rely on an existing db connection
            Dir.chdir(File.join(__dir__, 'models')) do
                require './system'
                require './config'
                require './value'
                require './group'
                require './error'
                require './alert'
                require './action'
                require './metric'
                require './script'
                require './command_config'
                require './script_command'
                require './config_metric'
                require './active_alert'
            end
        end

        def self.start_timers
            # a fixed number of hours of data are kept in the database. once an
            # hour, old values and files are removed. if all values of a metric
            # are removed from a system, the accompanying metric record is also
            # removed.
            cleanup_task = Concurrent::TimerTask.new do
                attempts = 0
                complete = false

                while !complete && attempts < MAX_CLEAN_ATTEMPTS
                    begin
                        puts "Cleaning, attempt #{attempts + 1}"
                        start = Time.now
                        Perus::Server::DB.cleanup
                        Stats.cleaned!(Time.now - start)

                        start = Time.now
                        @db.execute('vacuum')
                        Stats.vacuumed!(Time.now - start)

                        complete = true
                        puts "Cleaning complete"
                        
                    rescue
                        attempts += 1
                        if attempts < MAX_CLEAN_ATTEMPTS
                            puts "Clean failed, will reattempt after short sleep"
                            sleep(5)
                        end
                    end
                end

                if !complete
                    puts "Clean failed more than MAX_CLEAN_ATTEMPTS"
                    Stats.cleaned!('failed')
                end
            end

            # fire every hour
            cleanup_task.execution_interval = 60 * 60
            cleanup_task.execute

            # alerts can be process intensive, so to keep page refreshes
            # responsive the 'active' state of an alert for each system is
            # cached so lookups can be done against the db, rather than running
            # each alert for each system on a page load.
            cache_alerts_task = Concurrent::TimerTask.new do
                if Server.ping_queue.empty?
                    begin
                        start = Time.now
                        Perus::Server::Alert.cache_active_alerts
                        Stats.alerts_cached!(Time.now - start)
                    rescue
                        Stats.alerts_cached!('failed')
                    end
                end
            end

            cache_alerts_task.execution_interval = Server.options.cache_alerts_secs
            cache_alerts_task.execute
        end

        def self.cleanup
            puts 'Cleaning old values and metrics'
            keep_hours = Server.options.keep_hours

            # remove old values
            min_timestamp = Time.now.to_i - (keep_hours * 60 * 60)
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
