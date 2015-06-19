module Metrics
    class HD < Metric
        option :drive, '/dev/sda1'
        
        def measure(results)
            percent = `df -h / | awk '#{options.drive} {print $5}'`
            results[:hd_used] = percent.to_i
        end
    end
end
