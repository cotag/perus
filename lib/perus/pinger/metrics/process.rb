module Metrics
    class Process < Metric
        description 'Measures percentage of RAM and CPU used by the process specified by "process_path".
                     The results are returned to the server under 2 metrics called "cpu_{name}" and
                     "mem_{name}". Valid values for "process_path" are contained in the pinger config file.'
        option :process_path, restricted: true
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
