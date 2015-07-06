module Commands
    class Upload < Command
        option :path

        def perform
            @file = File.new(options.path)
        end

        def cleanup
            @file.close unless @file.closed?
        end
    end
end
