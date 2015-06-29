class Server::Value < Sequel::Model
    plugin :validation_helpers
    one_to_one :group

    def validate
        super
        validates_presence [:system_id, :metric, :timestamp, :value]
    end
end
