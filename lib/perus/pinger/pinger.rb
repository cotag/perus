require 'rest-client'
require 'ostruct'
require 'json'
require 'uri'

class Perus::Pinger::Pinger
    def initialize
        # cache urls on initialisation since the urls depend on values known
        # at startup and that won't change over the object lifetime
        config_path = URI("/systems/#{Pinger.options.system_id}/config")
        pinger_path = URI("/systems/#{Pinger.options.system_id}/ping")
        server_uri  = URI(Pinger.options.server)

        @config_url = (server_uri + config_path).to_s
        @pinger_url = (server_uri + pinger_path).to_s
    end

    def reload_and_ping
        load_config
        ping
    end

    def load_config
        # load the system config by requesting it from the perus server
        json = JSON.parse(RestClient.get(@config_url))

        # load metric modules based on the config
        @metrics = json['metrics'].collect do |options|
            metric = Metrics.const_get(options['type'])
            metric.new(options['params'])
        end
    end

    def ping
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

        # uploads are sent separately to other results. replace the hash of
        # files with a list of keys so the server can store each file to disk
        if results.include?(:uploads)
            uploads = results.delete(:uploads)
            results[:uploads] = uploads.keys
            payload.merge!(uploads)
        end

        # send results to the perus server
        begin
            payload[:values] = JSON.dump(results)
            RestClient.post(@pinger_url, payload)
        ensure
            # cleanup temporary files etc.
            @metrics.each(&:cleanup)
        end
    end
end
