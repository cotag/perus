module Perus
    module Pinger
        Dir.chdir(__dir__) do
            # commands
            require './pinger/command'
            require './pinger/chrome_command'
            require './pinger/commands/chrome_execute'
            require './pinger/commands/chrome_navigate'
            require './pinger/commands/chrome_reload'
            require './pinger/commands/kill_process'
            require './pinger/commands/remove_path'
            require './pinger/commands/replace'
            require './pinger/commands/restart'
            require './pinger/commands/upload'
            require './pinger/commands/upgrade'
            require './pinger/commands/script'
            require './pinger/commands/sleep'
            require './pinger/commands/upstart_start'
            require './pinger/commands/upstart_stop'

            # metrics
            require './pinger/metrics/chrome'
            require './pinger/metrics/cpu'
            require './pinger/metrics/hd'
            require './pinger/metrics/mem'
            require './pinger/metrics/process'
            require './pinger/metrics/screenshot'
            require './pinger/metrics/temp'
            require './pinger/metrics/value'
            require './pinger/metrics/uptime'
            require './pinger/metrics/running'

            # pinger
            require './pinger/pinger'
        end

        # options file
        DEFAULT_PINGER_OPTIONS_PATH = '/etc/perus-pinger'
    end

    Pinger::Pinger.new.run if __FILE__ == $0
end
