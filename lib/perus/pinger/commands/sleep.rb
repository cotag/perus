module Perus::Pinger
    class Sleep < Command
        description 'Wait "duration" seconds before proceeding to the next command'
        option :duration

        def run
            sleep(options.duration.to_i)
        end
    end
end
