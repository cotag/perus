module Metrics
    # commands and metrics are essentially the same thing - they take a set of
    # parameters and run a command on a client system. metrics return results
    # in a formatted way to the server, commands can return results, or may
    # simply inform the server that they were run. metrics are also intended to
    # run every ping, while commands are run once.
    class Metric < Pinger::Command
        def measure(results)
            # results[:name] = value
        end
    end

    class UploadMetric < Metric
        def measure(results)
            results[:uploads] ||= {}
            attach(results[:uploads])
        end

        def attach(uploads)
            # uploads[:name] = File like object
        end
    end
end
