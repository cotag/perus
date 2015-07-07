module Metrics
    class Uptime < Metric
        description 'Runs the uptime command and returns the result'
        
        def measure(results)
            results[:uptime] = `uptime`.strip
        end
    end
end
