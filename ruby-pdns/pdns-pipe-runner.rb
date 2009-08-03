#!/usr/bin/ruby

require 'pdns.rb'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

conffile = "/etc/nagger/nagger.cfg"

opts.each do |opt, arg|
    case opt
        when '--config'
            conffile = arg
    end
end


Pdns::Runner.new(conffile)