require 'iniparse'

module Perus
    class Options
        def initialize
            @defaults = {}
        end

        def load(path, defaults)
            if File.exists?(path)
                user_options = IniParse.parse(IO.read(path)).to_h
            else
                user_options = {}
            end

            # options are only one level deep, so resolve conflicts
            # by just merging the two conflicting hashes again
            @options = defaults.merge(user_options) do |key, default, user|
                default.merge(user)
            end
        end

        def method_missing(name, *params, &block)
            if @options.include?(name.to_s)
                @options[name.to_s]
            else
                @options['__anonymous__'][name.to_s]
            end
        end

        def [](name)
            @options[name]
        end
    end
end
