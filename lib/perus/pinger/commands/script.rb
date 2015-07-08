module Perus::Pinger
    class Script < Command
        option :commands
        abstract!

        def run
            actions = []
            results = []
            late_actions = []

            options.commands.each do |config|
                begin
                    command = ::Perus::Pinger.const_get(config['type'])
                    actions << command.new(config['options'], config['id'])
                rescue => e
                    if config['id']
                        results[config['id']] = e.inspect
                    else
                        puts 'Error - action does not have an associated id'
                        p config
                    end
                end
            end

            actions.each do |action|
                begin
                    result = action.run

                    if result.instance_of?(Proc)
                        late_actions << result
                        result = true
                    end

                    results << result
                rescue => e
                    results << e.inspect
                end
            end

            failed = results.any? {|result| result.is_a?(String)}
            return results.join(', ') if failed

            if late_actions.empty?
                true
            else
                Proc.new do
                    late_actions.each do |code|
                        begin
                            code.call
                        rescue => e
                            puts 'Error running late action'
                            puts e.inspect
                        end
                    end
                end
            end
        end
    end
end
