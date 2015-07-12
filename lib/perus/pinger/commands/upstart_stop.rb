module Perus::Pinger
    class UpstartStop < Command
        description 'Stop the upstart job specified with "job". Valid values
                     for "job" are contained in the pinger config file.'
        option :job, restricted: true

        def run
            result = shell("sudo stop #{option.job}")
            true # shell will capture any errors
        end
    end
end
