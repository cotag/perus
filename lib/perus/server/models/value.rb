module Perus::Server
    class Value < Sequel::Model
        plugin :validation_helpers
        many_to_one :system

        def validate
            super
            validates_presence [:system_id, :metric, :timestamp]
        end
    end
end
