module Metrics
    class CPU < Metric
        def measure(results)
            percent = `grep 'cpu ' /proc/stat | awk '{print (1 - ($5 / ($2+$3+$4+$5+$6+$7+$8)))*100}'`
            results[:all_cpu] = percent.to_f
        end
    end
end
