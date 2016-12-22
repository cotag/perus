# Usage: rake import:systems_csv['/usr/local/bundle/gems/perus-0.1.34/lib/tasks/import.csv','test']

# csv filename as argument

# Read csv in line by line
#   assume first line is the title
#   check the room name, search existing systems
#               if its new, create the system
#                       add the 3 zones listed on the same line
#               if it's existing, return the system that matches
#       Add the device to the system

Name = 0
LogicalName = 1
IP = 2
Orientation = 3
Group = 4


f = '/usr/local/bundle/gems/perus-0.1.34/lib/tasks/import.csv'

    do_save = true


        systems = {}
        devices = {}

# read line by line
File.foreach(f).with_index do |line, line_num|
    next if line_num == 0 || line.strip.empty?
    raw = line.strip.split(",")

    # Grab the System Information
    sys_name = "#{raw[Name]}"
    sys_logical_name = "#{raw[LogicalName]}"
    sys_ip = "#{raw[IP]}"
    system = systems[sys_ip]

    if system.nil?
        sys = Perus::Server::System.where(ip: sys_ip).first

        unless sys
            sys = Perus::Server::System.new
            sys.name = sys_name
            sys.logical_name = sys_logical_name
            sys.orientation = "#{raw[Orientation]}"
            sys.group_id = "#{raw[Group]}"
            sys.config_id = 1
            sys.ip = sys_ip
            sys.links = "TV: http://control.dhlav.local/tv-control/#/?tv=#{sys.logical_name}\nEngine: http://control.dhlav.local/backoffice/#/?system=#{sys.logical_name}"

            tries = 0
            begin
                sys.save if do_save
                puts "Created system #{sys.name}"
            rescue => e
                puts "error: #{e.message}"
                puts sys.errors.messages if sys.errors

                if tries <= 8
                    sleep 1
                    tries += 1
                    retry
                else
                    puts "FAILED TO CREATE SYSTEM #{system_name}"
                    raise "FAILED TO CREATE SYSTEM #{system_name}"
                end
            end
        end

        system = sys
        systems[sys_ip] = sys
    end
end
