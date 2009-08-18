#!/usr/bin/ruby

require 'pdns.rb'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

conffile = "/etc/pdns/pdns-ruby-backend.cfg"

opts.each do |opt, arg|
    case opt
        when '--config'
            conffile = arg
    end
end


begin
    Pdns::Runner.new(conffile)
rescue Exception => e
    Pdns.fatal("Runner loop exited: #{e}")
    Pdns.fatal(e.backtrace)
end
