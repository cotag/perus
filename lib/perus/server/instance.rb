require 'optparse'
require 'thin'

class Server::Instance
    def run
        config_path = '/etc/perus-server'

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

        Server::Config.load(config_path)
        Server::DB.start

        Thin::Server.start(
            Server::Config.listen,
            Server::Config.port.to_i,
            Server::App
        )
    end

    def self.run
        server = Server::Instance.new
        server.run
    end
end
