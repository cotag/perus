module Metrics
    class Value < Metric
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
