module Commands
    class Restart < Pinger::Command
        description 'Restarts the client computer'

        def perform
            -> { `sudo reboot` }
        end
    end
end
