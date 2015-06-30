require './options'

module Pinger
    # metrics
    require './pinger/metric'
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
    require './pinger/instance'
    require './pinger/pinger'

    # options
    def self.options
        @options ||= Perus::Options.new
    end
end

Pinger::Instance.run if __FILE__ == $0
