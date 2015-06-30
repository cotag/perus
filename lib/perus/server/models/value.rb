class Server::Value < Sequel::Model
    plugin :validation_helpers
    many_to_one :group

    def validate
        super
        validates_presence [:system_id, :metric, :timestamp]
    end
end
