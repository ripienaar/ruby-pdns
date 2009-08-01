#!/usr/bin/ruby

require 'pdns.rb'
require 'pp'

module Pdns
    newrecord("puppet.pinetecltd.net", :type => :query) do |query, answer|
        answer.qclass query[:qclass]
        answer.qtype :A
        answer.ttl 3600

        answer.content "3.3.3.3"
    end

    newrecord("foo.pinetecltd.net", :type => :query) do |query, answer|
        answer.qclass query[:qclass]
        answer.qtype :A
        answer.ttl 3600

        answer.content "1.2.3.4"
        answer.content "4.3.2.1"
    end
end


pdns = Pdns::Resolvers.new

r = pdns.do_query({:qname    => "puppet.pinetecltd.net",
              :qclass => :IN,
              :qtype => :ANY,
              :id => 1,
              :localip => "127.0.0.2",
              :remoteip => "207.192.75.148" })

pp r.response

r = pdns.do_query({:qname    => "foo.pinetecltd.net",
              :qclass => :IN,
              :qtype => :ANY,
              :id => 1,
              :localip => "127.0.0.2",
              :remoteip => "207.192.75.148" })
pp r.response
