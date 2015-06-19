#!/usr/bin/ruby
require 'perus/pinger'
require 'optparse'

config_path = '/etc/perus-pinger'

ARGV.options do |opts|
    opts.banner = "Usage: perus-pinger [options]"

    opts.on('-c', '--config', String, 'Path to config file (default: /etc/perus-pinger)') do |c|
        config_path = c
    end

    opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
    end

    opts.parse!
end

pinger = Pinger.new(config_path)
pinger.ping
