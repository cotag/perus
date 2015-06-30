require 'optparse'
require 'thin'

DEFAULT_OPTIONS_PATH = '/etc/perus-server'
DEFAULT_OPTIONS = {
    'uploads_dir' => './uploads',
    'uploads_url' => 'http://localhost:3000/uploads/',
    'db_path' => './perus.db',
    'listen' => '0.0.0.0',
    'port' => 3000,
    'site_name' => 'Perus'
}

class Server::Instance
    def run
        options_path = DEFAULT_OPTIONS_PATH

        ARGV.options do |opts|
            opts.banner = "Usage: perus-server [options]"

            opts.on('-c', '--config', String, 'Path to config file (default: /etc/perus-server)') do |c|
                options_path = c
            end

            opts.on('-h', '--help', 'Prints this help') do
                puts opts
                exit
            end

            opts.parse!
        end

        self.class.init(options_path)
        Thin::Server.start(
            Server.options.listen,
            Server.options.port.to_i,
            Server::App
        )
    end

    def self.init(options_path = DEFAULT_OPTIONS_PATH)
        Server.options.load(options_path, DEFAULT_OPTIONS)
        Server::DB.start
    end

    def self.run
        server = Server::Instance.new
        server.run
    end
end
