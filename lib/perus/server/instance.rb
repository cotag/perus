require 'optparse'
require 'thin'

DEFAULT_OPTIONS_PATH = '/etc/perus-server'

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
            Server::Options.listen,
            Server::Options.port.to_i,
            Server::App
        )
    end

    def self.init(options_path = DEFAULT_OPTIONS_PATH)
        Server::Options.load(options_path)
        Server::DB.start
    end

    def self.run
        server = Server::Instance.new
        server.run
    end
end
