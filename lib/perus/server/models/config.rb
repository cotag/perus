module Perus::Server
    class Config < Sequel::Model
        plugin :validation_helpers
        one_to_many :systems
        one_to_many :config_metrics, order: :order

        def metric_hashes
            config_metrics.collect(&:config_hash)
        end

        def largest_order
            if config_metrics.empty?
                0
            else
                config_metrics.last.order
            end
        end

        def can_delete?
            systems_dataset.empty?
        end

        def in_maintenance?
            return false unless maintenance.is_a?(String)
            from, to = maintenance.split('-')
            now = Time.now

            from_hour, from_min = from.split(':').map(&:to_i)
            return false if now.hour < from_hour
            return false if now.hour == from_hour && now.min < from_min

            to_hour, to_min = to.split(':').map(&:to_i)
            return false if now.hour > to_hour
            return false if now.hour == to_hour && now.min > to_min

            true
        end

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end

        def after_destroy
            super
            config_metrics.each(&:destroy)
        end
    end
end
