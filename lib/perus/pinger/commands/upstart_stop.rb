module Perus::Pinger
    class UpstartStop < Command
        description 'Stop the upstart job specified with "job". Valid values
                     for "job" are contained in the pinger config file.'
        option :job, restricted: false

        def run
            result = shell("sudo stop #{options.job}")
            true # shell will capture any errors
        end
    end
end
