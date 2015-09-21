module Perus::Pinger
    class Chrome < ChromeCommand
        description 'Connects to Chrome with the remote debugger and counts the
                     number of warnings and errors currently in the console of
                     the top Chrome window. The URL of the page is also sent
                     and can be compared to an expected string in an alert.'
        metric!
                     
        def run
            # we use a debugging protocol connection to read the console messages
            # in the top level window to count the number of warnings and errors
            warning_count = 0
            error_count = 0

            execute(['{"id":1,"method":"Console.enable"}']) do |json|
                if json['method'] == 'Console.messageAdded'
                    level = json['params']['message']['level']
                    if level == 'error'
                        error_count += 1
                    elsif level == 'warning'
                        warning_count += 1
                    end
                end
            end

            return {} if @page.nil?

            {
                chrome_warnings: warning_count,
                chrome_errors: error_count,
                chrome_url: @page['url']
            }
        end
    end
end
