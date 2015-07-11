module Perus::Pinger
    class Uptime < Command
        description 'Runs the uptime command and returns the result'
        metric!
        
        def run
            {uptime: shell('uptime').strip}
        end
    end
end
