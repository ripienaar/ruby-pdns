#!/usr/bin/ruby

require 'getoptlong'
require 'pdns'

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
    Pdns.config = Pdns::Config.new(conffile)
    stats = Pdns::Stats.new

    stats.aggregate!
    stats.to_file("#{Pdns.config.statsdir}/aggregate.pstat")
rescue Exception => e
    STDERR.puts("Could not aggregate PDNS stats: #{e}")
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
