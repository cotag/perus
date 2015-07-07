module Metrics
    class Mem < Metric
        description 'Measures overall RAM usage as a percentage on the client'

        def measure(results)
            percent = `cat /proc/meminfo | awk '{if ($1=="MemTotal:") total = $2; if ($1 == "MemFree:") free = $2;} END {print (1 - (free / total))*100}'`
            results[:mem_all] = percent.to_f
        end
    end
end
