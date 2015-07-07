module Metrics
    class Temp < Metric
        description 'Measures the temperature of "device" on the client. By default, this will be a CPU.'
        option :device, default: 'Physical id 0'
        
        def measure(results)
            if `uname -s`.strip == 'Darwin'
                degrees = `istats cpu temp`.split[2].match(/([0-9\.]+)/)[0]
            else
                degrees = `sensors | grep "#{options.device}:"`.match(/#{options.device}:\s+(\S+)/)[1]
            end
            results[:temp] = degrees.to_f
        end
    end
end
