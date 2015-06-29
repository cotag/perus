class Server::System < Sequel::Model
    plugin :validation_helpers
    many_to_one :config
    many_to_one :group
    one_to_one  :value

    def validate
        super
        validates_presence  :name
        validates_unique    :name
    end
end
