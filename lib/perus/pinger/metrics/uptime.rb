module Metrics
    class Uptime < Metric
        def measure(results)
            results[:uptime] = `uptime`.strip
        end
    end
end
