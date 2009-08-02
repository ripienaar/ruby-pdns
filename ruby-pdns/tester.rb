#!/usr/bin/ruby

require 'pdns.rb'
require 'pp'

module Pdns
    newrecord("puppet.pinetecltd.net", :type => :record) do |query, answer|
        answer.qclass query[:qclass]
        answer.qtype :CNAME
        answer.ttl 3600

        answer.content "foo.pinetecltd.net"
    end

    newrecord("foo.pinetecltd.net", :type => :record) do |query, answer|
        answer.qclass query[:qclass]
        answer.qtype :A
        answer.ttl 600

        case country(query[:remoteip])
            when "DE"
                answer.content "1.2.3.4"
            else
                answer.content "4.3.2.1"
                answer.content "1.2.3.4"
	    end
    end
end


pdns = Pdns::Runner.new
exit

puts("Looking up puppet.pinetecltd.net from 207.192.75.148")
r = pdns.do_query({:qname    => "puppet.pinetecltd.net",
              :qclass => :IN,
              :qtype => :ANY,
              :id => 1,
              :localip => "127.0.0.2",
              :remoteip => "207.192.75.148" })

print_response r

puts("\n\nLooking up foo.pinetecltd.net from 78.47.195.198")
r = pdns.do_query({:qname    => "foo.pinetecltd.net",
              :qclass => :IN,
              :qtype => :ANY,
              :id => 1,
              :localip => "127.0.0.2",
              :remoteip => "78.47.195.198" })

print_response r

puts("\n\nLooking up foo.pinetecltd.net from 207.192.75.148")
r = pdns.do_query({:qname    => "foo.pinetecltd.net",
              :qclass => :IN,
              :qtype => :ANY,
              :id => 1,
              :localip => "127.0.0.2",
              :remoteip => "207.192.75.148" })

print_response r
# vi:tabstop=4:expandtab:ai:filetype=ruby
