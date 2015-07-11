module Perus::Server
    class Config < Sequel::Model
        plugin :validation_helpers
        one_to_many :systems
        one_to_many :config_metrics, order: 'name asc'

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
