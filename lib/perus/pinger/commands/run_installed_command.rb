module Perus::Pinger
    class RunInstalledCommand < Command
        description 'Run the command specified with "path". Valid values for
                     "path" are contained in the pinger config file.'
        option :path, restricted: false

        def run
            shell(options.path)
        end
    end
end
