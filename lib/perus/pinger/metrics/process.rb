module Perus::Pinger
    class Process < Command
        description 'Measures percentage of RAM and CPU used by the process
                     specified by "process_path". The results are returned to
                     the server under 2 metrics called "cpu_{name}" and
                     "mem_{name}". Valid values for "process_path" are
                     contained in the pinger config file.'
        option :process_path, restricted: true
        option :name
        metric!

        def run
            path = options.process_path.gsub("/", "\\/")
            cpu, mem = shell("ps aux | awk '/#{path}/ {cpu += $3; mem += $4} END {print cpu, mem;}'").split

            if darwin?
                core_count = shell('sysctl -n hw.ncpu')
            else
                core_count = shell("cat /proc/cpuinfo | grep processor | awk '{count += 1} END {print count}'")
            end

            {
                "cpu_#{options.name}" => cpu.to_f / core_count.to_i,
                "mem_#{options.name}" => mem.to_f
            }
        end
    end
end
