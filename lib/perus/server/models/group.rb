module Perus::Server
    class Group < Sequel::Model
        plugin :validation_helpers
        one_to_many :systems
        
        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end

        def after_destroy
            super

            # rather than deleting all systems in a group, each system in the
            # group is just removed from the group instead. this is better than
            # accidentally removing a group and all related system data.
            systems.each do |system|
                system.group_id = nil
                system.save
            end
        end
    end
end
