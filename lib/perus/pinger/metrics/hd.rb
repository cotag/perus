module Metrics
    class HD < Metric
        option :drive, '/dev/sda1'
        
        def measure(results)
            regex = "/^#{options.drive.gsub("/", "\\/")}/"
            percent = `df -h / | awk '#{regex} {print $5}'`
            results[:hd_used] = percent.to_i
        end
    end
end
