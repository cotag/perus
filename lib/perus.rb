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

elsif ARGV[0] == 'console'
    require 'irb'

    # start in the Server namespace
    include Perus::Server

    # console is used to access the database. initialise server options to find
    # the db path and start the database connection.
    Server.load_options
    DB.start

    # remove the arg otherwise irb will try to load a file named 'console'
    ARGV.shift
    IRB.start
end
