class Server::Value < Sequel::Model
    plugin :validation_helpers

    def validate
        super
        validates_presence [:system_id, :metric, :timestamp, :value]
    end
end
