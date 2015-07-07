module Perus::Server
    class Config < Sequel::Model
        plugin :validation_helpers
        one_to_many :systems

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end
    end
end
