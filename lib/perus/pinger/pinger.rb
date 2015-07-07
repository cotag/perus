require 'securerandom'
require 'rest-client'
require 'ostruct'
require 'json'
require 'uri'

DEFAULT_OPTIONS = {
    'system_id' => 1,
    'server' => 'http://localhost:3000/'
}

module Perus::Pinger
    class Pinger
        attr_reader :options

        def initialize(options_path = DEFAULT_OPTIONS_PATH)
            @options = Perus::Options.new
            options.load(options_path, DEFAULT_OPTIONS)

            # cache urls on initialisation since the urls depend on values known
            # at startup and that won't change over the object lifetime
            config_path = URI("/systems/#{options.system_id}/config")
            pinger_path = URI("/systems/#{options.system_id}/ping")
            server_uri  = URI(options.server)

            @config_url = (server_uri + config_path).to_s
            @pinger_url = (server_uri + pinger_path).to_s

            @metrics = []
            @metric_results = {}
            @metric_errors = {}

            @commands = []
            @command_results = {}
            @late_commands = []
        end

        def run
            load_config
            run_metrics
            run_commands
            send_response
            cleanup
        end

        #----------------------
        # configuration
        #----------------------
        def load_config
            # load the system config by requesting it from the perus server
            json = JSON.parse(RestClient.get(@config_url))
            json['metrics'] ||= []
            json['commands'] ||= []

            # load metric and command modules based on the config
            json['metrics'].each do |config|
                begin
                    metric = ::Perus::Pinger.const_get(config['type'])
                    @metric_errors[metric.name] ||= []
                    @metrics << metric.new(config['options'])
                rescue Exception => e
                    if e.is_a?(NameError)
                        @metric_errors[config['type']] = e.inspect
                    else
                        @metric_errors[metric.name] << e.inspect
                    end
                end
            end

            json['commands'].each do |config|
                begin
                    command = ::Perus::Pinger.const_get(config['type'])
                    @commands << command.new(config['options'])
                rescue Exception => e
                    if config['options']['id']
                        @command_results[config['options']['id']] = e.inspect
                    end
                end
            end
        end

        #----------------------
        # run
        #----------------------
        def run_metrics
            @metrics.each do |metric|
                begin
                    result = metric.run
                    @metric_results.merge!(result)
                rescue Exception => e
                    @metric_errors[metric.class.name] << e.inspect
                end
            end
        end

        def run_commands
            @commands.each do |command|
                begin
                    result = command.run

                    if result.instance_of?(Proc)
                        @late_commands << result
                        result = true
                    end

                    @command_results[command.id] = result

                rescue Exception => e
                    @command_results[command.id] = e.inspect
                end
            end
        end

        #----------------------
        # response
        #----------------------
        def add_to_payload(payload, field, results)
            results.each do |name, val|
                next unless val.instance_of?(File)
                uuid = SecureRandom.uuid
                results[name] = {file: uuid}
                payload[uuid] = val
            end

            payload[field] = JSON.dump(results)
        end

        def send_response
            # prepare the response and replace file results with a reference
            # to the uploaded file. files are sent as top level parameters in
            # the payload, while metric and command results are sent as a json
            # object with a reference to these files.
            payload = {}
            add_to_payload(payload, 'metrics', @metric_results)
            add_to_payload(payload, 'commands', @command_results)

            # metric_errors is created with a key for each metric type. most
            # metrics should run without any errors, so remove these entries
            # before adding errors to the payload.
            @metric_errors.reject! {|metric, errors| errors.empty?}
            add_to_payload(payload, 'metric_errors', @metric_errors)

            begin
                RestClient.post(@pinger_url, payload)
            rescue Exception => e
                puts 'Ping failed with exception'
                puts e.inspect
            end
        end

        #----------------------
        # cleanup
        #----------------------
        def cleanup
            @metrics.each(&:cleanup)
            @commands.each(&:cleanup)
            @late_commands.each(&:call)
        end
    end
end
