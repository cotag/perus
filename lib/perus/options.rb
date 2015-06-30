require 'inifile'

module Perus
    class Options
        def initialize()
            @defaults = {}
        end

        def load(path, defaults)
            user_options = IniFile.load(path)
            user_options ||= {}  # if no user options were provided
            @options = defaults.merge(user_options)
        end

        def method_missing(name, *params, &block)
            @options[name.to_s]
        end
    end
end
