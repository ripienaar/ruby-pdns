module Pdns
    class Resolvers
        include Pdns

        @@resolvers = {}

        # Adds a resolver to the list of known resolvers
        # 
        # name - should be the DNS RR to answer for
        # options - hash with :type => :query being the only option
        # block - the code to be executed for each lookup
        def self.add_resolver(name, options = {}, &block)
            @@resolvers[name] = {:options => options, :block => block}
        end

        # Performs an actual query and returns a Pdns::Response class
        #
        # query is a hash that should have all of the following:
        #
        # {:qname    => "foo.pinetecltd.net",
        #  :qclass => :IN,
        #  :qtype => :ANY,
        #  :id => 1,
        #  :localip => "127.0.0.2",
        #  :remoteip => "207.192.75.148" }
        #
        # The fields map directly to what Power DNS will in version 2 queries.
        #
        # Before a query can be answered a resolver should have been added using add_resolver
        def do_query(query)
            qname = query[:qname]
            answer = Pdns::Response.new(qname)

            if @@resolvers.has_key?(qname)
                r = @@resolvers[qname]

                r[:block].call(query, answer)
            else
                raise Pdns::UnknownRecord, "Cannot find a configured record for #{qname}"
            end

            answer
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
