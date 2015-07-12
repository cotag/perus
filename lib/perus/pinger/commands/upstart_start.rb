module Perus::Pinger
    class UpstartStart < Command
        description 'Start the upstart job specified with "job". Valid values
                     for "job" are contained in the pinger config file.'
        option :job, restricted: true

        def run
            result = shell("sudo start #{options.job}")
            true # shell will capture any errors
        end
    end
end
