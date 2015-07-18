require 'thread'
require 'thin'

DEFAULT_SERVER_OPTIONS = {
    '__anonymous__' => {
        'uploads_dir' => './uploads',
        'uploads_url' => 'http://localhost:3000/uploads/',
        'db_path' => './perus.db',
        'listen' => '0.0.0.0',
        'port' => 5000,
        'site_name' => 'Perus',
        'url_prefix' => '/',
        'keep_hours' => 24,
        'cache_alerts_secs' => 20,
        'stats_path' => '/var/perus.stats'
    },
    'db' => {
        'username' => '',
        'password' => ''
    }
}

module Perus::Server
    class Server
        def initialize(options_path = DEFAULT_SERVER_OPTIONS_PATH, environment = 'development')
            self.class.load_options(options_path)
            ENV['RACK_ENV'] = environment

            # initialise/migrate the db and start cleanup/caching timers
            DB.start
            DB.start_timers

            # ping data is processed in a thread pool
            Thread.new do
                while true
                    ping = Server.ping_queue.pop
                    begin
                        ping.call
                    rescue => e
                        puts e.inspect
                        if e.backtrace.is_a?(Array)
                            puts e.backtrace.join("\n") + "\n"
                        end
                    end
                end
            end
        end

        def run
            Thin::Server.start(
                self.class.options.listen,
                self.class.options.port.to_i,
                App
            )
        end

        def self.ping_queue
            @ping_queue ||= Queue.new
        end

        def self.options
            @options ||= Perus::Options.new
        end

        def self.load_options(path = DEFAULT_SERVER_OPTIONS_PATH)
            options.load(path, DEFAULT_SERVER_OPTIONS)
        end
    end
end
