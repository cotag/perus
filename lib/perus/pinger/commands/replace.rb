module Perus::Pinger
    class Replace < Command
        description 'Looks for the string matched by "grep" in the file
                     specified by "path" and replaces it with "replacement".
                     Valid values for "path" are contained in the pinger
                     config file.'
        option :path, restricted: true
        option :grep
        option :replacement

        def run
            text = IO.read(options.path)
            text.gsub!(/#{options.grep}/, options.replacement)
            IO.write(options.path, text)
            true
        end
    end
end
