module Commands
    class KillProcess < Pinger::Command
        description 'Kills all instances of a process. Valid values for "process_name" are contained
                     in the pinger config file.'
        option :process_name, restricted: true
        option :signal, default: 'KILL'

        def perform
            result = `killall -#{option.signal} #{option.process_name}`
            result.include?('no process found') ? result : true
        end
    end
end
