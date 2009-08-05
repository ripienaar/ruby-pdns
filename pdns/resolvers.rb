module Pdns
    # class that holds instances of all resolvers, does queries against them
    # and loads them from disk.
    #
    # Queries can BeMixed.Case.Com and should be returned the same, this is a bit of a pain
    # so we by convention store our record code with lower case and then downcase calls to it
    # leaving it up to this class to deal with the case complexities, without these handles we
    # will get ServFail's
    class Resolvers
        include Pdns

        @@resolvers = {}
        @@resolverstats = {}

        # Adds a resolver to the list of known resolvers
        # 
        # name - should be the DNS RR to answer for
        # options - hash with :type => :record being the only option
        # block - the code to be executed for each lookup
        def self.add_resolver(name, options = {}, &block)
            name.downcase!

            Pdns::Runner.debug("Adding resolver #{name} into list of workers")
            @@resolvers[name] = {:options => options, :block => block, :loadedat => Time.now}
            @@resolverstats[name] = {:usagecount => 0}
        end

        # Clears out all the resolvers that are supported, this should be called before loading new ones from disk
        # for example to be sure you don't have any weird leftovers
        #
        # It only clears the @@resolvers hash not the @@resolverstats hash to keep stats across reloads
        def self.empty!
            @@resolvers = {}
        end

        # Use this to figure out if a specific request could be answered by 
        # a registered resolver
        def can_answer?(request)
            @@resolvers.has_key?(request[:qname].downcase)
        end

        # Returns the type that was specified when the record was created
        # this is like :record or future supported modes
        def type(request)
            if can_answer?(request)
                name = request[:qname].downcase
                return @@resolvers[name][:options][:type]
            end
        end

        # Returns the resolver for a request, query names gets downcases from the request
        def get_resolver(request)
            if can_answer?(request)
                qname = request[:qname].downcase
                @@resolvers[qname] 
            else
                raise(Pdns::UnknownRecord, "Can't answer queries for #{request[:qname]}")
            end
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
        def do_query(request)
            qname = request[:qname]
            answer = Pdns::Response.new(qname)

            # Set sane defaults
            answer.id request[:id].to_i
            answer.qclass request[:qclass]

            begin
                r = get_resolver(request)

                r[:block].call(request, answer)
                @@resolverstats[qname.downcase][:usagecount] += 1
            rescue Exception => e
                raise Pdns::UnknownRecord, "Cannot find a configured record for #{qname}: #{e}"
            end

            answer
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
