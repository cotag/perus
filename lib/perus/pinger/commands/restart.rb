module Perus::Pinger
    class Restart < Command
        description 'Restarts the client computer'

        def run
            -> { `sudo reboot` }
        end
    end
end
