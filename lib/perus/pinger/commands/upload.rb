module Perus::Pinger
    class Upload < Command
        description 'Uploads a file from the client to the server. Valid values
                     for "path" are contained in the pinger config file.'
        option :path, restricted: true

        def run
            @file = File.new(options.path)
        end

        def cleanup
            @file.close unless @file.nil? || @file.closed?
        end
    end
end
