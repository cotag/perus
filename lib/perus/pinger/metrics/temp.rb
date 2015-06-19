module Metrics
    class Temp < Metric
        option :device, 'Physical id 0'
        
        def measure(results)
            degrees = `sensors | grep "#{options.device}:"`.match(/#{options.device}:\s+(\S+)/)[1]
            results[:temp] = degrees.to_f
        end
    end
end
