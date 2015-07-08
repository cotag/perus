module Perus::Server
    class Action < Sequel::Model
        plugin :validation_helpers
        many_to_one :system
        serialize_attributes :json, :file
        serialize_attributes :json, :options

        def validate
            super
            validates_presence [:system_id, :command]
        end
    end
end
