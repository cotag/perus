require './options'

module Perus
    module Pinger
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

        # pinger
        require './pinger/pinger'

        # options file
        DEFAULT_OPTIONS_PATH = '/etc/perus-pinger'
    end

    Pinger::Pinger.new.run if __FILE__ == $0
end
