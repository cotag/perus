require 'chronic_duration'

module Perus::Server
    class ActiveAlert < Sequel::Model
        many_to_one :alert
        many_to_one :system

        def severity
            alert.severity
        end

        def active_for
            ChronicDuration.output(Time.now.to_i - timestamp, format: :short)
        end

        def self.add(alert, system)
            ActiveAlert.create(
                system_id: system.id,
                alert_id: alert.id,
                timestamp: Time.now.to_i
            )
        end
    end
end
