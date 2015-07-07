module Metrics
    class Value < Metric
        description 'Searches the file specified by "path" with the regular expression specified by "grep".
                     Returns the resulting string to the server under the metric called "name". Valid values
                     for "path" are contained in the pinger config file.'
        option :path
        option :grep
        option :name
        
        def measure(results)
            line = `cat #{options.path} | grep #{options.grep}`
            value = line.match(Regexp.compile(options.match))[1]
            results[options.name.to_sym] = value
        end
    end
end
