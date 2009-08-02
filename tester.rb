#!/usr/bin/ruby

require 'pdns.rb'

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
