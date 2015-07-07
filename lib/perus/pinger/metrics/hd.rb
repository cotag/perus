module Metrics
    class HD < Metric
        description 'Measures percentage of disk space used on the specified drive'
        option :drive
        
        def measure(results)
            regex = "/^#{options.drive.gsub("/", "\\/")}/"
            percent = `df -h / | awk '#{regex} {print $5}'`
            results[:hd_used] = percent.to_i
        end
    end
end
