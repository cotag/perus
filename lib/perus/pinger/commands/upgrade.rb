module Perus::Pinger
    class Upgrade < Command
        description 'Upgrades Perus on the client machine'
        option :sudo, default: false

        def run
            if options.sudo
                result = shell('sudo gem update perus')
            else
                result = shell('gem update perus')
            end

            result.include?('ERROR') ? result : true
        end
    end
end
