module Perus::Pinger
    class Value < Command
        description 'Searches the file specified by "path" with the regular
                     expression specified by "grep". Returns the resulting
                     string to the server under the metric called "name". Valid
                     values for "path" are contained in the pinger config file.'
        option :path, restricted: true
        option :grep
        option :name
        metric!
        
        def run
            grep = optipns.grep.gsub('"', '\\"')
            line = shell(%q[cat #{options.path} | egrep "#{grep}"])
            value = line.match(Regexp.compile(options.match))[1]
            {options.name => value}
        end
    end
end
