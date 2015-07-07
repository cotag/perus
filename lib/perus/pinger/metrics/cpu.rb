module Perus::Pinger
    class CPU < Command
        description 'Measures overall system CPU usage as a percentage on the
                     client.'
        metric!

        def run
            if `uname -s`.strip == 'Darwin'
                percent = 100 - `iostat -n 0`.split("\n")[2].split[2].to_i
            else
                percent = `grep 'cpu ' /proc/stat | awk '{print (1 - ($5 / ($2+$3+$4+$5+$6+$7+$8)))*100}'`
            end
            
            {cpu_all: percent.to_f}
        end
    end
end
