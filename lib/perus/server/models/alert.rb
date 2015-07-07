class Server::Alert < Sequel::Model
    def execute(systems)
        systems.select do |system|
            system.instance_eval(code)
        end
    end
end