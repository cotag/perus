module Commands
    class Restart < Command
        def perform
            -> { `sudo reboot` }
        end
    end
end
