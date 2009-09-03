module Pdns
    # The workhorse class for the framework, speads directly to PDNS
    # via STDIN and STDOUT. 
    #
    # It requires your PDNS to speak ABI version 2.
    class Runner
        attr_reader :resolver, :config

        # By default the runner will be a normal runner speaking to PDNS but when 
        # passing anything for mode it will turn into a tester that will initialize
        # the records, parse configs and everything it just wont handshake and speak
        # PDNS.  Programatically you can then construct queries and send them to 
        # the resolvers do_query method.
        # 
        # The entire main loop will be bypassed, so no periodic loading of records etc
        # will be done
        def initialize(configfile = "/etc/pdns/pipe-backend.cfg", mode="runner")
            STDOUT.sync = true
            STDIN.sync = true
            STDERR.sync = true
        
            @config = Pdns::Config.new(configfile)
            @resolver = Pdns::Resolvers.new
            @lastmaint = Time.now

            if mode == "runner"
                Pdns.warn("Runner starting")

                load_records

                handshake

                pdns_loop

                STDOUT.flush

                Pdns.warn("Runner exiting")
            elsif
                Pdns.warn("Tester starting")

                load_records
            end
        end

        # load all files ending in .prb from the records dir
        def load_records
            Pdns::Resolvers.empty!

            if File.exists?(@config.records_dir)
                records = Dir.new(@config.records_dir) 
                records.entries.grep(/\.prb$/).each do |r|
                    Pdns.warn("Loading new record from #{@config.records_dir}/#{r}")
                    Kernel.load("#{@config.records_dir}/#{r}")
                end
            else
                raise("Can't find records dir #{@config.records_dir}")
            end

            # store when we last loaded, the main loop will call this
            # methods once a configurable interval 
            @lastrecordload = Time.now
        end

        # General maintenance handler script
        def do_maint
            if (Time.now - @lastrecordload) > @config.reload_interval
                Pdns.debug("Reloading records from disk due to reload_interval")
                load_records
            end

            if (Time.now - @lastmaint) > @config.maint_interval
                Pdns.debug "Starting maintenance routines"

                @lastmaint = Time.now

                begin
                    File.open("#{@config.statsdir}/#{Time.now.to_i}.pstat", 'w') do |f|
                        stats = @resolver.stats
    
                        stats.each_key do |r|
                            stat = stats[r]

                            f.puts("#{r}\tusagecount:#{stat[:usagecount]}\ttotaltime:#{stat[:totaltime]}")
                        end
                    end
                rescue Exception => e
                    Pdns.error("Could not process stats: #{e}")
                end

                Pdns.debug "Ending maintenance routines"
            end
        end

        # Listens on STDIN for messages from PDNS and process them
        def pdns_loop
            while true
                r = select([STDIN], nil, nil, @config.maint_interval.to_i)

                # did we get data in time for the timeout fro the select?
                # see issue #2 for what this is all about
                unless r == nil
                    pdnsinput = STDIN.gets.chomp
    
                    Pdns.debug("Got '#{pdnsinput}' from pdns")
                    t = pdnsinput.split("\t")
    
                    if t.size == 7
                        handle_seven_param_request(pdnsinput)
                    elsif t.size == 2
                        handle_two_param_request(pdnsinput)
                    else
                        handle_garbage_request(pdnsinput)
                    end

                    do_maint
                else
                    do_maint 
                end
            end
        end

        private
        # handles a typical 7 param request from PDNS
        #
        # Requests like:
        # Q foo.my.net  IN  ANY -1  1.2.3.4 0.0.0.0
        def handle_seven_param_request(pdnsinput)
            t = pdnsinput.split("\t")

            request = {:qname       => t[1],
                       :qclass      => t[2].to_sym,
                       :qtype       => t[3].to_sym,
                       :id          => t[4],
                       :remoteip    => t[5],
                       :localip     => t[6]}

            if @resolver.can_answer?(request)
                Pdns.debug("Handling lookup for #{request[:qname]} from #{request[:remoteip]}")

                begin
                    answers = @resolver.do_query(request)
                rescue Pdns::UnknownRecord => e
                    Pddns.info("Could not serve request for #{request[:qname]} record was not found")

                    puts("FAIL")
                    next
                rescue Pdns::RecordCallError => e
                    Pdns.error("Could not serve request for #{request[:qname]} record block failed: #{e}")

                    puts("FAIL")
                    next
                rescue Exception => e
                    Pdns.error("Got unexpected exception while serving #{request[:qname]}: #{e}")
                    puts("FAIL")
                    next
                end

                # Backends are like entire zones, so in the :record type of entry we need to have
                # an SOA still this really is only to keep PDNS happy so we just fake it in those cases.
                #
                # PDNS loves doing ANY requests, it'll do a lot of those even if clients do like TXT only
                # this is some kind of internal optimisation, not helping us since we dont cache but
                # so we return SOA in cases where:
                #
                # - records type is :record, in future we might support a zone type it would need to do 
                #   its own SOAs then
                # - only if we're asked for SOA or ANY records, else we'll confuse things
                if (@resolver.type(request) == :record) && (request[:qtype] == :SOA || request[:qtype] == :ANY)
                    ans = answers.fudge_soa(@config.soa_contact, @config.soa_nameserver)

                    Pdns.debug(ans)
                    puts ans
                end

                # SOA requests should not get anything else than the fudged answer above
                if request[:qtype] != :SOA
                    answers.response.each do |ans| 
                        Pdns.debug(ans)
                        puts ans
                    end
                end

                Pdns.debug("END")
                puts("END")
            else
               Pdns.info("Asked to serve #{request[:qname]} but don't know how")

               # Send an END and not a FAIL, FAIL results in PDNS sending SERVFAIL to the clients
               # which is just very retarded, #fail.
               #
               # The example in the docs and tarball behaves the same way.
               puts("END")
            end
        end

        # handles requests from PDNS that we just dont know what to do with
        def handle_garbage_request(pdnsinput)
            Pdns.error("PDNS sent '#{pdnsinput}' which made no sense")
            puts("FAIL")
        end

        # Handles requests like AXFR    1 from PDNS
        def handle_two_param_request(pdnsinput)
            Pdns.debug("END")
            puts("END")
        end

        # Handshakes with PDNS, if PDNS is not set up for ABI version 2 handshake will fail
        # and the backend will exit
        def handshake
            unless STDIN.gets.chomp =~ /HELO\t2/
                Pdns.error("Did not receive an ABI version 2 handshake correctly from pdns")
                puts("FAIL")
                exit
            end

            Pdns.info("Ruby PDNS backend starting with PID #{$$}")

            puts("OK\tRuby PDNS backend starting")
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
