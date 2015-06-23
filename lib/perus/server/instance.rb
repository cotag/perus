require 'optparse'
require 'thin'

DEFAULT_CONFIG_PATH = '/etc/perus-server'

class Server::Instance
    def run
        config_path = DEFAULT_CONFIG_PATH

        ARGV.options do |opts|
            opts.banner = "Usage: perus-server [options]"

            opts.on('-c', '--config', String, 'Path to config file (default: /etc/perus-server)') do |c|
                config_path = c
            end

            opts.on('-h', '--help', 'Prints this help') do
                puts opts
                exit
            end

            opts.parse!
        end

        self.class.init(config_path)
        Thin::Server.start(
            Server::Config.listen,
            Server::Config.port.to_i,
            Server::App
        )
    end

    def self.init(config_path = DEFAULT_CONFIG_PATH)
        Server::Config.load(config_path)
        Server::DB.start
    end

    def self.run
        server = Server::Instance.new
        server.run
    end
end
