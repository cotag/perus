class Server::System < Sequel::Model
    plugin :validation_helpers

    def validate
        super
        validates_presence [:name]
        validates_unique :name
    end
end
