module Perus::Pinger
    class KillProcess < Command
        description 'Kills all instances of a process. Valid values for
                     "process_name" are contained in the pinger config file.'
        option :process_name, restricted: true
        option :signal, default: 'TERM'

        def run
            result = shell("killall -#{options.signal} #{options.process_name}")
            true # shell will capture any errors
        end
    end
end
