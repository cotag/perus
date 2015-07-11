module Perus::Pinger
    class HD < Command
        description 'Measures the percentage of disk space currently used on
                     the specified drive.'
        option :drive
        metric!
        
        def run
            regex = "/^#{options.drive.gsub("/", "\\/")}/"
            percent = shell("df -h / | awk '#{regex} {print $5}'")
            {hd_used: percent.to_i}
        end
    end
end
