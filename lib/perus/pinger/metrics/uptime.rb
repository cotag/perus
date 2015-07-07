module Perus::Pinger
    class Uptime < Command
        description 'Runs the uptime command and returns the result'
        metric!
        
        def run
            {uptime: `uptime`.strip}
        end
    end
end
