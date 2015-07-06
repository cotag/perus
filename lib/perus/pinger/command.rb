require 'ostruct'

class Pinger::Command
    attr_reader :options

    def self.option(name, default = nil)
        @defaults ||= {}
        @defaults[name] = default
    end

    def self.defaults
        @defaults || {}
    end

    def initialize(options)
        defaults = self.class.defaults
        @options = OpenStruct.new(defaults.merge(options))
    end

    def perform
        # run command
    end

    def cleanup
        # remove temporary files etc.
    end
end
