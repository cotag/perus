require 'faye/websocket'
require 'eventmachine'
require 'rest-client'
require 'json'

module Metrics
    class Chrome < Metric
        option :timeout_seconds, 2
        option :host, 'localhost'
        option :port, 9222

        def measure(results)
            # discover the first page shown in chrome
            pages = JSON.parse(RestClient.get("http://#{options.host}:#{options.port}/json"))
            pages.reject! {|page| page['url'].include?('chrome-extension')}
            page = pages.first

            # capture the page url and websocket endpoint for debugging
            page_url = page['url']
            ws_url = page['webSocketDebuggerUrl']

            # we use a debugging protocol connection to read the console messages
            # in the top level window to count the number of warnings and errors
            warning_count = 0
            error_count = 0

            EM.run do
                ws = Faye::WebSocket::Client.new(ws_url)

                ws.on :error do |event|
                    puts "Chrome error: #{event}"
                    EM.stop_event_loop
                end

                ws.on :close do |event|
                    EM.stop_event_loop
                end

                ws.on :message do |event|
                    json = JSON.parse(event.data)

                    if json['method'] == 'Console.messageAdded'
                        level = json['params']['message']['level']
                        if level == 'error'
                            error_count += 1
                        elsif level == 'warning'
                            warning_count += 1
                        end
                    end
                end

                # request console messages
                ws.send('{"id":1,"method":"Console.enable"}')

                # cutoff console message loading after N seconds
                EM.add_timer(option.timeout_seconds) do
                    ws.close
                end
            end

            results[:chrome_warnings] = warning_count
            results[:chrome_errors] = error_count
            results[:chrome_url] = page_url
        end
    end
end
