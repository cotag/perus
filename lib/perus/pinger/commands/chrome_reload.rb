module Commands
    class ChromeReload < ChromeCommand
        description 'Reloads the top Chrome window. When "ignore_cache" is true, the effect is equivalent
                     to performing a force reload.'
        option :ignore_cache, default: false

        def perform
            execute(['{"id":1,"method":"Page.reload"}'])
            true
        end
    end
end
