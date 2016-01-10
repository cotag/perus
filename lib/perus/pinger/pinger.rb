require 'securerandom'
require 'rest-client'
require 'ostruct'
require 'json'
require 'uri'

DEFAULT_PINGER_OPTIONS = {
    '__anonymous__' => {
        'server' => 'http://127.0.0.1:5000/'
    },

    # restricted values
    'Value' => {
        'path' => []
    },

    'Screenshot' => {
        'path' => []
    },

    'Process' => {
        'process_path' => []
    },

    'Upload' => {
        'path' => []
    },

    'Replace' => {
        'path' => []
    },

    'RemovePath' => {
        'path' => []
    },

    'KillProcess' => {
        'process_name' => []
    },

    'Running' => {
        'process_path' => []
    },

    'UpstartStart' => {
        'job' => []
    },

    'UpstartStop' => {
        'job' => []
    },

    'ServiceStart' => {
        'job' => []
    },

    'ServiceStop' => {
        'job' => []
    },

    'RunInstalledCommand' => {
        'path' => []
    }
}

module Perus::Pinger
    class Pinger
        def self.options
            @options ||= Perus::Options.new
        end

        def initialize(options_path = DEFAULT_PINGER_OPTIONS_PATH)
            Pinger.options.load(options_path, DEFAULT_PINGER_OPTIONS)
            @server_uri  = URI(Pinger.options.server)

            @metrics = []
            @metric_results = {}
            @metric_errors = {}

            @actions = []
            @action_results = {}
            @late_actions = []
        end

        def run
            load_config
            run_actions
            run_metrics
            send_response
            cleanup
        end

        #----------------------
        # configuration
        #----------------------
        def load_config
            if Pinger.options.system_id.nil?
                config_path = URI("systems/config_for_ip")
            else
                config_path = URI("systems/#{Pinger.options.system_id}/config")
            end

            config_url = (@server_uri + config_path).to_s

            # load the system config by requesting it from the perus server
            tries = 0
            json = begin
                JSON.parse(RestClient.get(config_url))
            rescue => e
                if tries < 5
                    tries += 1
                    sleep 2
                    retry
                else
                    raise e
                end 
            end

            json['metrics'] ||= []
            json['actions'] ||= []
            @system_id = json['id']

            if @system_id == 'nil'
                raise 'This system is unknown to the server'
            end

            # load metric and command modules based on the config
            json['metrics'].each do |config|
                begin
                    if ::Perus::Pinger.const_defined?(config['type'])
                        metric = ::Perus::Pinger.const_get(config['type'])
                        @metric_errors[metric.name] ||= []
                        @metrics << metric.new(config['options'])
                    else
                        @metric_errors[config['type']] = format_exception(e)
                    end
                rescue => e
                    @metric_errors[metric.name] << format_exception(e)
                end
            end

            json['actions'].each do |config|
                begin
                    command = ::Perus::Pinger.const_get(config['type'])
                    @actions << command.new(config['options'], config['id'])
                rescue => e
                    if config['id']
                        @action_results[config['id']] = format_exception(e)
                    else
                        puts 'Error - action does not have an associated id'
                        p config
                    end
                end
            end
        end

        #----------------------
        # run
        #----------------------
        def format_exception(e)
            if e.backtrace.empty?
                e.inspect
            else
                "#{e.inspect}\n#{e.backtrace.first}"
            end
        end

        def run_metrics
            @metrics.each do |metric|
                begin
                    result = metric.run
                    @metric_results.merge!(result)
                rescue => e
                    @metric_errors[metric.class.name] << format_exception(e)
                end
            end
        end

        def run_actions
            @actions.each do |action|
                begin
                    result = action.run

                    if result.instance_of?(Proc)
                        @late_actions << result
                        result = true
                    end

                    @action_results[action.id] = result

                rescue => e
                    @action_results[action.id] = format_exception(e)
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
            # the payload, while metric and action results are sent as a json
            # object with a reference to these files.
            payload = {}
            add_to_payload(payload, 'metrics', @metric_results)
            add_to_payload(payload, 'actions', @action_results)

            # metric_errors is created with a key for each metric type. most
            # metrics should run without any errors, so remove these entries
            # before adding errors to the payload.
            @metric_errors.reject! {|metric, errors| errors.empty?}
            add_to_payload(payload, 'metric_errors', @metric_errors)

            pinger_path = URI("systems/#{@system_id}/ping")
            pinger_url = (@server_uri + pinger_path).to_s

            begin
                RestClient.post(pinger_url, payload)
            rescue => e
                puts 'Ping failed with exception'
                puts format_exception(e)
            end
        end

        #----------------------
        # cleanup
        #----------------------
        def cleanup
            @metrics.each do |metric|
                begin
                    metric.cleanup
                rescue => e
                    puts 'Error running metric cleanup'
                    puts format_exception(e)
                end
            end

            @actions.each do |action|
                begin
                    action.cleanup
                rescue => e
                    puts 'Error running action cleanup'
                    puts format_exception(e)
                end
            end

            @late_actions.each do |code|
                begin
                    code.call
                rescue => e
                    puts 'Error running late action'
                    puts format_exception(e)
                end
            end
        end
    end
end
