#!/usr/bin/ruby

require 'getoptlong'
require 'pdns'

opts = GetoptLong.new(
    [ '--record', '-r', GetoptLong::REQUIRED_ARGUMENT],
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

conffile = "/etc/pdns/pdns-ruby-backend.cfg"
record = nil

opts.each do |opt, arg|
    case opt
        when '--record'
            record = arg
        when '--config'
            conffile = arg
        end
end

unless record
    puts "Please choose a record to display using --record"
    exit 1
end

begin
    Pdns.config = Pdns::Config.new(conffile)
    stats = Pdns::Stats.new

    stats.load_file("#{Pdns.config.statsdir}/aggregate.pstat")

    if stats.include_record?(record)
        r = stats.recordstats(record)

        puts("usagecount:#{r[:usagecount]} totaltime:#{r[:totaltime]}")
    else
        raise("Cannot find stats for record #{record}")
    end
rescue Exception => e
    STDERR.puts(e)
    exit 1
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
