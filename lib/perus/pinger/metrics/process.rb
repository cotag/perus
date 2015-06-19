module Metrics
    class Process < Metric
        option :process_path
        option :name

        def measure(results)
            path = options.gsub("/", "\\\\\\/")
            cpu, mem = `ps aux | awk '/#{path}/ {cpu += $3; mem += $4} END {print cpu, mem;}'`.split
            core_count = `cat /proc/cpuinfo | grep processor | awk '{count += 1} END {print count}'`
            results["#{option.name}_cpu"] = cpu.to_f / core_count.to_i
            results["#{option.name}_mem"] = mem.to_f
        end
    end
end
