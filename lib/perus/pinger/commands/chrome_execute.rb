module Perus::Pinger
    class ChromeExecute < ChromeCommand
        description 'Executes JavaScript in the top Chrome window. The result
                     of the execution is stored and sent to the server.'
        option :js

        def run
            result = false
            command = '{"id":1,"method":"Runtime.evaluate","params":{"expression":"' + options.js.gsub('"', '\\"') + '","objectGroup":"perus","returnByValue":true}}'
            
            execute([command]) do |message|
                if message.include?('id') && message['id'] == 1
                    if message.include?('result')
                        result = message['result'].to_s
                    elsif message.include?('error')
                        result = message['error'].to_s
                    else
                        result = false
                    end

                    # clean up any memory used by the executed command
                    send_command('{"id":2,"method":"Runtime.releaseObjectGroup","params":{"objectGroup":"perus"}}')
                end
            end

            result
        end
    end
end
