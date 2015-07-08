require 'faye/websocket'
require 'eventmachine'
require 'rest-client'
require 'json'

module Perus::Pinger
    class ChromeCommand < Command
        option :timeout_seconds, default: 2
        option :host, default: 'localhost'
        option :port, default: 9222
        abstract!

        def send_command(command)
            @ws.send(command)
        end

        def execute(commands, &message_callback)
            # discover the first page shown in chrome
            pages = JSON.parse(RestClient.get("http://#{options.host}:#{options.port}/json"))
            pages.reject! {|page| page['url'].include?('chrome-extension')}
            @page = pages.first

            EM.run do
                @ws = Faye::WebSocket::Client.new(@page['webSocketDebuggerUrl'])

                @ws.on :error do |event|
                    puts "Chrome error: #{event}"
                    EM.stop_event_loop
                end

                @ws.on :close do |event|
                    EM.stop_event_loop
                end

                @ws.on :message do |event|
                    if block_given?
                        json = JSON.parse(event.data)
                        message_callback.call(json)
                    end
                end

                # send each command, responses will appear
                commands.each do |command|
                    send_command(command)
                end

                # cutoff console message loading after N seconds
                EM.add_timer(options.timeout_seconds) do
                    @ws.close
                end
            end
        end
    end
end
