module Commands
    class Replace < Pinger::Command
        description 'Looks for the string matched by "grep" in the file specified by "path" and replaces it
                     with "replacement". Valid values for "path" are contained in the pinger config file.'
        option :path, restricted: true
        option :grep
        option :replacement
    end
end
