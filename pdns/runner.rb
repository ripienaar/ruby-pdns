module Pdns
    class Runner
        @logger = nil

        def initialize
            STDOUT.sync = true
            STDIN.sync = true
            STDERR.sync = true
        
            @resolver = Pdns::Resolvers.new

            @logger = Logger.new("/tmp/pdns-pipe.log", 10, 102400)

            handshake

            pdns_loop
        end

        private
        def pdns_loop
            STDIN.each do |pdnsinput|
                pdnsinput.chomp!

                t = pdnsinput.split("\t")

                @logger.debug("Got '#{pdnsinput}' from pdns")

                if t.size == 7
                    request = {:qname       => t[1],
                               :qclass      => t[2].to_sym,
                               :qtype       => t[3].to_sym,
                               :id          => t[4],
                               :remoteip    => t[5],
                               :localip     => t[6]}

                    if @resolver.can_answer?(request)
                        @logger.debug("Handling lookup for #{request[:qname]} from #{request[:remoteip]}")

                        answers = @resolver.do_query(request)

                        answers.response.each do |ans| 
                            @logger.debug(ans)
                            puts ans
                        end

                       @logger.debug("END")
                       puts("END")
                    else
                       @logger.error("Asked to serve #{request[1]} but don't know how")
                       puts("FAIL")
                    end
                elsif t.size == 2
                    @logger.debug("END")
                    puts("END")
                else
                    @logger.error("PDNS sent '#{pdnsinput}' which made no sense")
                    puts("FAIL")
                end
            end
        end

        def handshake
            unless STDIN.gets.chomp =~ /HELO\t2/
                @logger.error("Did not receive a BI version 2 handshake correctly from pdns")
                puts("FAIL")
            end

            @logger.info("Ruby PDNS #{$$} backend starting")

            puts("OK\tRuby Bayes PDNS backend starting")
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
