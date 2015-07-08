require 'thin'

DEFAULT_SERVER_OPTIONS = {
    'uploads_dir' => './uploads',
    'uploads_url' => 'http://localhost:3000/uploads/',
    'db_path' => './perus.db',
    'listen' => '0.0.0.0',
    'port' => 3000,
    'site_name' => 'Perus'
}

module Perus::Server
    class Server
        def initialize(options_path = DEFAULT_SERVER_OPTIONS_PATH)
            self.class.options.load(options_path, DEFAULT_SERVER_OPTIONS)
            DB.start
        end

        def run
            Thin::Server.start(
                self.class.options.listen,
                self.class.options.port.to_i,
                App
            )
        end

        def self.options
            @options ||= Perus::Options.new
        end
    end
end
