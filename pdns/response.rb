module Pdns
    # Class that holds a response, the 'answer' variable in the record block will be
    # an instance of this 
    class Response
        # Valid query types we understand
        VALIDQTYPES = [:A, :CNAME, :SOA, :NS, :SRV, :MX, :TXT]

        # Valid response types we understand
        VALIDQCLASSES = [:IN]

        def initialize(qname)
            @response = {:qtype => :A, :content => [], :qclass => :IN, :ttl => 3600, :id => 1, :shuffle => true}
            @response[:qname] = qname
        end

        # Returns a hash representing the response, the query content
        # gets shuffled in case it's a multi record answer
        def response
            @response[:content].shuffle! if @response[:shuffle]
            
            ans = []

            # users can send back a 2 element array that would override the type - A, ANY, TXT, NS etc - of just that response
            @response[:content].each do |a|
                if a.class == Array
                    ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{a[0].to_s}\t#{@response[:ttl]}\t#{@response[:id]}\t#{a[1]}"
                else
                    ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{@response[:qtype]}\t#{@response[:ttl]}\t#{@response[:id]}\t#{a}"
                end
            end

            ans
        end

        # Comes up with a fake SOA record that should be enough to keep PDNS from handing out ServFails #fail
        def fudge_soa(nameserver, contact)
            ans = "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\tSOA\t#{@response[:ttl]}\t#{@response[:id]}\t#{nameserver}. #{contact}. 1 1800 3600 604800 3600"

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
        def id(t)
            if t.class == Fixnum
                @response[:id] = t
            else
                raise Pdns::InvalidID, "ID must be integer"
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

        # If the response should be shuffled or not
        def shuffle(s)
            if s.class == TrueClass or s.class == FalseClass
                @response[:shuffle] = s
            else
                raise Pdns::InvalidShuffle, "shuffle can be either true or false"
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
