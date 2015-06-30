require 'optparse'

DEFAULT_OPTIONS_PATH = '/etc/perus-pinger'
DEFAULT_OPTIONS = {
    'system_id' => 1,
    'server' => 'http://localhost:3000/',
    'system_config' => '/etc/perus-system-config'
}

class Pinger::Instance
    def run
        options_path = DEFAULT_OPTIONS_PATH

        ARGV.options do |opts|
            opts.banner = "Usage: perus-pinger [options]"

            opts.on('-c', '--config', String, 'Path to config file (default: /etc/perus-pinger)') do |c|
                options_path = c
            end

            opts.on('-h', '--help', 'Prints this help') do
                puts opts
                exit
            end

            opts.parse!
        end

        Pinger.options.load(options_path, DEFAULT_OPTIONS)
        pinger = Pinger::Pinger.new
        pinger.reload_and_ping
    end

    def self.run
        pinger = Pinger::Instance.new
        pinger.run
    end
end
