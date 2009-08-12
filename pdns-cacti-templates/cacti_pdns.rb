#!/usr/bin/ruby
# Simple script which converts PowerDNS stats into Cacti standard data input format

output = `/sbin/service pdns dump`
print output.gsub("=", ":").split(",").join(" ")
