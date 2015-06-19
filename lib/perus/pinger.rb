require 'rest-client'
require 'ostruct'
require 'json'

# metrics
require './pinger/metric'
require './pinger/metrics/chrome'
require './pinger/metrics/cpu'
require './pinger/metrics/hd'
require './pinger/metrics/mem'
require './pinger/metrics/process'
require './pinger/metrics/screenshot'
require './pinger/metrics/temp'
require './pinger/metrics/value'

class Pinger
    attr_reader :config

    def initialize(config_path)
        json = JSON.load(open(config_path))
        @config = OpenStruct.new(json)

        @metrics = config.metrics.collect do |options|
            metric = Metrics.const_get(options['type'])
            metric.new(options['params'])
        end
    end

    def ping
        screenshot_file = nil
        results = {}
        payload = {}

        @metrics.each do |metric|
            begin
                metric.measure(results)
            rescue Exception => e
                results[:errors] ||= {}
                results[:errors][metric.class.name] ||= []
                results[:errors][metric.class.name] << e.to_s
            end
        end

        # uploads are sent separately to other results
        if results.include?(:uploads)
            payload.merge(results.delete(:uploads))
        end

        # send results to the perus server
        payload[:data] = JSON.dump(results)
        RestClient.post(config.server_url, payload)

        # cleanup temporary files etc.
        @metrics.each(&:cleanup)
    end
end
