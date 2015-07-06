module Commands
    class ChromeRefresh < Command
        option :timeout_seconds, 2
        option :host, 'localhost'
        option :port, 9222
        
        def perform
        end
    end
end
