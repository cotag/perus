module Commands
    class ChromeNavigate < ChromeCommand
        description 'Changes the URL of the top Chrome window to "url"'
        option :url

        def perform
            execute([%q{{"id":1,"method":"Page.navigate","params":{"url":"#{options.url}"}}}])
            true
        end
    end
end
