module Perus::Pinger
    class ChromeExecute < ChromeCommand
        description 'Executes JavaScript in the top Chrome window. The result
                     of the execution is stored and sent to the server.'
        option :js

        def run
            execute([%q{{"id":1,"method":"Runtime.evaluate""params":{"expression":"#{js}","objectGroup":"perus","returnByValue":true}}}])
            true
        end
    end
end
