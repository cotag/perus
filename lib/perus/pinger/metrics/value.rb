module Perus::Pinger
    class Value < Command
        description 'Searches the file specified by "path" with the regular
                     expression specified by "grep". Returns the resulting
                     string to the server under the metric called "name". Valid
                     values for "path" are contained in the pinger config file.'
        option :path
        option :grep
        option :name
        metric!
        
        def run
            line = `cat #{options.path} | grep #{options.grep}`
            value = line.match(Regexp.compile(options.match))[1]
            {options.name => value}
        end
    end
end
