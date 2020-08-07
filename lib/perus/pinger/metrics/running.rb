module Perus::Pinger
    class Running < Command
        description 'Reports "yes" if "process_path" is running, "no"
                     otherwise. Valid values for "process_path" are contained
                     in the pinger config file.'
        option :process_path, restricted: false
        metric!
        
        def run
            begin
                ps_result = shell("ps aux | grep -v grep | grep #{options.process_path}")
            rescue ShellCommandError
                ps_result = ''
            end
            
            metric_name = "#{File.basename(options.process_path)}_running"
            {metric_name => ps_result.empty? ? 'no' : 'yes'}
        end
    end
end
