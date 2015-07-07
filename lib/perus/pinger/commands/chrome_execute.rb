module Commands
    class ChromeExecute < ChromeCommand
        description 'Executes JavaScript in the top Chrome window. The result of the execution is
                     stored and can be viewed on the server.'
        option :js

        def perform
            execute([%q{{"id":1,"method":"Runtime.evaluate""params":{"expression":"#{js}","objectGroup":"perus","returnByValue":true}}}])
            true
        end
    end
end
