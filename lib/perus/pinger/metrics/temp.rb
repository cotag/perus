module Perus::Pinger
    class Temp < Command
        description 'Measures the temperature of "device" on the client. By
                     default, this will be a CPU.'
        option :device, default: 'Physical id 0'
        metric!
        
        def run
            if darwin?
                degrees = shell('istats cpu temp').split[2].match(/([0-9\.]+)/)[0]
            else
                degrees = shell(%q[sensors | grep "#{options.device}:"]).match(/#{options.device}:\s+(\S+)/)[1]
            end

            {temp: degrees.to_f}
        end
    end
end
