require 'ostruct'

module Metrics
    class Metric
        attr_reader :options

        def self.option(name, default = nil)
            @defaults ||= {}
            @defaults[name] = default
        end

        def self.defaults
            @defaults || {}
        end

        def initialize(options)
            defaults = self.class.defaults
            @options = OpenStruct.new(defaults.merge(options))
        end

        def measure(results)
            # results[:name] = value
        end

        def cleanup
            # remove temporary files etc.
        end
    end

    class UploadMetric < Metric
        def measure(results)
            results[:uploads] ||= {}
            attach(results[:uploads])
        end

        def attach(uploads)
            # uploads[:name] = File like object
        end
    end
end
