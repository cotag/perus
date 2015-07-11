module Perus::Pinger
    class Mem < Command
        description 'Measures overall RAM usage as a percentage on the client.'
        metric!

        def run
            percent = shell(%q[cat /proc/meminfo | awk '{if ($1=="MemTotal:") total = $2; if ($1 == "MemFree:") free = $2;} END {print (1 - (free / total))*100}'])
            {mem_all: percent.to_f}
        end
    end
end
