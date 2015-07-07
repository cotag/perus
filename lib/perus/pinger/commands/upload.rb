module Commands
    class Upload < Pinger::Command
        description 'Uploads a file from the client to the server. Valid values for "path" are
                     contained in the pinger config file.'
        option :path, restricted: true

        def perform
            @file = File.new(options.path)
        end

        def cleanup
            @file.close unless @file.nil? || @file.closed?
        end
    end
end
