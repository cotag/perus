module Metrics
    class Process < Metric
        option :process_path
        option :name

        def measure(results)
            path = options.process_path.gsub("/", "\\\\\\/")
            cpu, mem = `ps aux | awk '/#{path}/ {cpu += $3; mem += $4} END {print cpu, mem;}'`.split
            if `uname -s`.strip == 'Darwin'
                core_count = `sysctl -n hw.ncpu`
            else
                core_count = `cat /proc/cpuinfo | grep processor | awk '{count += 1} END {print count}'`
            end

            results["cpu_#{options.name}"] = cpu.to_f / core_count.to_i
            results["mem_#{options.name}"] = mem.to_f
        end
    end
end
