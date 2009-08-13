module Pdns
    # Class that holds a response, the 'answer' variable in the record block will be
    # an instance of this 
    class Response
        # Valid query types we understand
        VALIDQTYPES = [:A, :CNAME, :NS, :SRV, :MX, :TXT]

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
                    if a.size == 2
                        ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{a[0].to_s}\t#{@response[:ttl]}\t#{@response[:id]}\t#{a[1]}"
                    elsif a.size == 3
                        ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{a[1].to_s}\t#{a[0]}\t#{@response[:id]}\t#{a[2]}"
                    end
                else
                    ans << "DATA\t#{@response[:qname]}\t#{@response[:qclass]}\t#{@response[:qtype]}\t#{@response[:ttl]}\t#{@response[:id]}\t#{a}"
                end
            end

            ans
        end

        # Returns a nice string representation of the response
        def to_s
            output = "Response for #{@response[:qname]}:\n"
            output += "\t  Default TTL: #{@response[:ttl]}\n"
            output += "\t Default Type: #{@response[:qtype]}\n"
            output += "\tDefault Class: #{@response[:qclass]}\n"
            output += "\t           ID: #{@response[:id]}\n"
            output += "\t      Shuffle: #{@response[:shuffle]}\n"

            output += "\n\tRecords:\n"

            ans = response

            ans.each do |a|
                a.gsub!(/DATA\s+/, "")
                output += "\t               #{a}\n"
            end

            output
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
        #
        # It will take variable number of arguments, pass it one argument
        # and the record will use the default ttl, rtype etc.
        #
        # Pass it two arguments to set special types like A, ANY, TXT etc. Three
        # arguments would be ttl, type and address.
        #
        # Sample usages:
        #
        # answer.content "1.2.3.4"
        # answer.content [:A, "1.2.3.4"]
        # answer.content :A, "1.2.3.4"
        # answer.content 300, :A, "1.2.3.4"
        def content(*c)
            c = c.flatten

            if c.size == 1
                @response[:content] << c[0]
            elsif c.size == 2 || c.size == 3
                @response[:content] << c
            end
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
