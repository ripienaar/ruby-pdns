#!/usr/bin/ruby

# Simple script to update data stored in the external databases for pdns

require 'pdns.rb'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--record', '-r', GetoptLong::REQUIRED_ARGUMENT],
    [ '--key', '-k', GetoptLong::REQUIRED_ARGUMENT],
    [ '--value', '-v',  GetoptLong::REQUIRED_ARGUMENT],
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

conffile = "/etc/pdns/pdns-ruby-backend.cfg"
record = nil
key = nil
val = nil

opts.each do |opt, arg|
    case opt
        when '--key'
            key = arg
        when '--record'
            record = arg
        when '--value'
            val = arg
        when '--config'
            conffile = arg
    end
end


Pdns.config = Pdns::Config.new(conffile)
Pdns.extdata = Pdns::Extdata.new

begin
    Pdns.extdata.update(record, key, val)

    Pdns.extdata.loaddata
    puts YAML.dump(Pdns.extdata.all_data(record)[:data])

rescue Exception => e
    puts "Failed to update data: #{e}" 
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
