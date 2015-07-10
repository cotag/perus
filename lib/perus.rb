Dir.chdir(__dir__) do
    require './perus/options'
    require './perus/pinger'
    require './perus/server'
    require './perus/version'
end

if ARGV[0] == 'server'
    Perus::Server::Server.new.run
elsif ARGV[0] == 'pinger'
    Perus::Pinger::Pinger.new.run
end
