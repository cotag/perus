require 'ostruct'

module Perus::Pinger
    class Option
        attr_reader :name, :default, :restricted

        def initialize(name, settings)
            @name = name
            @default = settings[:default]
            @restricted = settings[:restricted] == true
        end

        def boolean?
            default.is_a?(TrueClass) || default.is_a?(FalseClass)
        end

        def process(results, values)
            value = values[name.to_s]

            if restricted
            end

            if value.nil? && default.nil?
                raise "#{name} is a required option"
            end

            results[name] = value || default
        end
    end

    class Command
        attr_reader :options, :id

        def self.human_name
            name.demodulize.underscore.humanize.titlecase
        end

        # set or get command/metric description
        def self.description(text = nil)
            if text
                @description = text
            else
                @description
            end
        end

        # add an option to the command/metric. both the class and instances
        # of the class have an options method. the class version returns a
        # list of Option objects representing possible options for the
        # command. the object version returns an OpenStruct hash of options
        # and their values (defaults merged with provided values)
        def self.option(name, option_settings = {})
            @options ||= []
            @options << Option.new(name, option_settings)
        end

        def self.options
            @options ||= []
        end

        def self.inherited(subclass)
            subclass.options.concat(self.options)
            Command.subclasses << subclass
        end

        def self.subclasses
            @subclasses ||= []
        end

        # command classes which are intended to run as metrics call this method
        def self.metric!
            @metric = true
        end

        def self.metric?
            @metric
        end

        def self.abstract!
            @abstract = true
        end

        def self.abstract?
            @abstract
        end

        # create a command instance and initialise it with the provided option
        # values (hash where keys are option names). any restricted options are
        # validated first, and an exception is thrown if the provided value is
        # not one of the allowed values for the option.
        def initialize(option_values, id = nil)
            @options = OpenStruct.new
            self.class.options.each do |option|
                option.process(@options, option_values)
            end

            # commands (not metrics) have ids that uniquely identify a command
            # instance and its response
            @id = id
        end

        def run
            # run command/metric, return types for a command are:
            # true: successful (will show as success on the server)
            # string: failed, string should provide the reason
            # file: file to upload
            # proc: code to run after returning success to server
            # hash: metrics are expected to only return a hash with
            # keys indicating metric names, and values restricted to
            # files, numerics and strings.
            # exceptions are caught and shown as errors on the server.
        end

        def cleanup
            # called after sending data to server. remove temporary
            # files etc.
        end
    end
end
