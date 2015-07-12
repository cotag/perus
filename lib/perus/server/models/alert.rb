module Perus::Server
    class Alert < Sequel::Model
        one_to_many :active_alerts

        def execute(system)
            system.instance_eval(code)
        end

        def execute_errors
            values[:errors]
        end

        def after_destroy
            super
            active_alerts.each(&:destroy)
        end

        def self.cache_active_alerts
            puts 'Caching active alerts'
            start = Time.now
            systems = System.all

            Alert.each do |alert|
                begin
                    # active_alerts are left as is if they are still active
                    currently_active = {}
                    alert.active_alerts.each do |active_alert|
                        currently_active[active_alert.system_id] = active_alert
                    end

                    # remove active alerts if they're no longer valid, add new
                    # ones as needed.
                    systems.each do |system|
                        active = alert.execute(system)
                        if active && !currently_active.include?(system.id)
                            ActiveAlert.add(alert, system)
                        elsif !active && currently_active.include?(system.id)
                            currently_active[system.id].destroy
                        end
                    end

                    # no errors occurred by this point, so remove the error
                    # string if it exists from a previous run
                    alert.errors = nil
                rescue => e
                    alert.errors = e.inspect
                end
                
                # update alert.errors
                alert.save
            end

            puts "Caching complete, took #{Time.now - start}s"
        end
    end
end
