module Pdns
    class Response
        # Valid query types we understand
        VALIDQTYPES = [:A, :CNAME, :SOA, :NS, :SRV]

        # Valid response types we understand
        VALIDQCLASSES = [:IN]

        def initialize(qname)
            @response = {:qtype => :A, :content => [], :qclass => :IN, :ttl => 3600}
            @response[:qname] = qname
        end

        # Returns a hash representing the response, the query content
        # gets shuffled in case it's a multi record answer
        def response
            @response[:content].shuffle!
            
            ans = []

            @response[:content].each do |a|
                ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{@response[:qtype]}\t#{a}"
            end

            ans
        end

        # Sets the response query type, validates it against VALIDQTYPES
        def qtype(t)
            if VALIDQTYPES.include? t
                @response[:qtype] = t
            else
                raise Pdns::UnknownQueryType, "Can't handle #{t} type queries"
            end
        end

        # Append content to teh answer, when called many times the
        # answers will be appended to the record
        def content(c)
            @response[:content] << c
        end

        # Sets the response query class, validates it against VALIDQCLASSES
        def qclass(c)
            if VALIDQCLASSES.include? c
                @response[:qclass] = c
            else
                raise Pdns::UnknownQueryClass, "Can't handle #{t} type queries"
            end
        end

        # Verifies the ttl is numeric and sets it into the response
        def ttl(t)
            if t.class == Fixnum
                @response[:ttl] = t
            else
                raise Pdns::InvalidTTL, "TTL must be integer"
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
