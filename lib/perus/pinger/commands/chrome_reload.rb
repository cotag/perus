module Perus::Pinger
    class ChromeReload < ChromeCommand
        description 'Reloads the top Chrome window. When "ignore_cache" is true
                     the effect is equivalent to performing a force reload.'
        option :ignore_cache, default: false

        def run
            result = false

            execute(['{"id":1,"method":"Page.reload"}']) do |message|
                if message.include?('id') && message['id'] == 1
                    if message.include?('result')
                        if message['result'] == {}
                            result = true
                        else
                            result = message['result'].to_s
                        end
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
