module Perus::Pinger
    class ServiceStart < Command
        description 'Start the init job specified with "job". Valid values
                     for "job" are contained in the pinger config file.'
        option :job, restricted: true

        def run
            result = shell("sudo service #{options.job} start")
            true # shell will capture any errors
        end
    end
end
