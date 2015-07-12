module Perus::Pinger
    class ServiceStop < Command
        description 'Stop the init job specified with "job". Valid values
                     for "job" are contained in the pinger config file.'
        option :job, restricted: true

        def run
            result = shell("sudo service #{options.job} stop")
            true # shell will capture any errors
        end
    end
end
