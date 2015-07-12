require 'concurrent'
require 'thin'

DEFAULT_SERVER_OPTIONS = {
    '__anonymous__' => {
        'uploads_dir' => './uploads',
        'uploads_url' => 'http://localhost:3000/uploads/',
        'db_path' => './perus.db',
        'listen' => '0.0.0.0',
        'port' => 3000,
        'site_name' => 'Perus',
        'url_prefix' => '/',
        'keep_hours' => 24,
        'cache_alerts_secs' => 20,
        'stats_path' => '/var/perus.stats'
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
        end

        def run
            Thin::Server.start(
                self.class.options.listen,
                self.class.options.port.to_i,
                App
            )
        end

        def self.ping_queue
            # ping data is processed in a thread pool
            @ping_queue ||= Concurrent::ThreadPoolExecutor.new(
                min_threads: 2,
                max_threads: 2,
                max_queue: 0
            )
        end

        def self.shutdown
            @ping_queue.shutdown
        end

        def self.options
            @options ||= Perus::Options.new
        end

        def self.load_options(path = DEFAULT_SERVER_OPTIONS_PATH)
            options.load(path, DEFAULT_SERVER_OPTIONS)
        end
    end
end
