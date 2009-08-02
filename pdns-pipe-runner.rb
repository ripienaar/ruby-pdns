#!/usr/bin/ruby

require 'pdns.rb'

Pdns::Runner.new("/etc/pdns/pdns-ruby-backend.cfg")
