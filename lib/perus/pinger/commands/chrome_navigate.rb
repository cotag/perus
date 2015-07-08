module Perus::Pinger
    class ChromeNavigate < ChromeCommand
        description 'Changes the URL of the top Chrome window to "url"'
        option :url

        def run
            result = false
            command = '{"id":1,"method":"Page.navigate","params":{"url":"' + options.url + '"}}'

            execute([command]) do |message|
                if message.include?('id') && message['id'] == 1
                    if message.include?('result')
                        result = true
                    elsif message.include?('error')
                        result = message['error'].to_s
                    else
                        result = message.to_s
                    end
                end
            end

            result
        end
    end
end
