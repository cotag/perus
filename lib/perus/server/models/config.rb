module Perus::Server
    class Config < Sequel::Model
        plugin :validation_helpers
        plugin :serialization
        
        one_to_many :systems
        serialize_attributes :json, :config

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end
    end
end
