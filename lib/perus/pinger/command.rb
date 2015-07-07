require 'ostruct'

class Pinger::Command
    attr_reader :options

    def self.option(name, options = {})
        @defaults ||= {}
        @defaults[name] = options[:default]
    end

    def self.defaults
        @defaults || {}
    end

    def self.description(desc = nil)
        if desc
            @description = desc
        else
            @description
        end
    end

    def initialize(options)
        defaults = self.class.defaults
        @options = OpenStruct.new(defaults.merge(options))
    end

    def perform
        # run command, return types are:
        # true: successful
        # string: failed, string gives the reason
        # file: file to upload
        # proc: commands to run after replying success to server
    end

    def cleanup
        # remove temporary files etc.
    end
end
