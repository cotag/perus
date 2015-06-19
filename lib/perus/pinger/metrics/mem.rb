module Metrics
    class Mem < Metric
        def measure(results)
            percent = `cat /proc/meminfo | awk '{if ($1=="MemTotal:") total = $2; if ($1 == "MemFree:") free = $2;} END {print (1 - (free / total))*100}'`
            results[:all_mem] = percent.to_f
        end
    end
end
