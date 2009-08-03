module Pdns
    # The workhorse class for the framework, speads directly to PDNS
    # via STDIN and STDOUT. 
    #
    # It requires your PDNS to speak ABI version 2.
    class Runner
        @@logger = nil

        def initialize(configfile = "/etc/pdns/pipe-backend.cfg")
            STDOUT.sync = true
            STDIN.sync = true
            STDERR.sync = true
        
            read_config(configfile, :logfile => "/var/log/pdns/pipe-backend.log",
                                    :loglevel => "info",
                                    :records_dir => "/etc/pdns/pipe_records")

            @resolver = Pdns::Resolvers.new

            @@logger = Logger.new(@config[:logfile], 10, 102400)
            @@logger.level = @config[:loglevel]

            Pdns::Runner.warn("Runner starting")

            load_records

            handshake
            pdns_loop

            Pdns::Runner.warn("Runner exiting")
        end

        ## methods other classes can use to acces our logger
        # logs at level INFO
        def self.info(msg)
            log(Logger::INFO, msg)
        end

        # logs at level WARN
        def self.warn(msg)
            log(Logger::WARN, msg)
        end

        # logs at level DEBUG
        def self.debug(msg)
            log(Logger::DEBUG, msg)
        end

        # logs at level FATAL
        def self.fatal(msg)
            log(Logger::FATAL, msg)
        end

        # logs at level ERROR
        def self.error(msg)
            log(Logger::ERROR, msg)
        end

        private
        # helper to do some fancy logging with caller information etc
        def self.log(severity, msg)
            @@logger.add(severity) { "#{$$} #{caller[3]}: #{msg}" }
        end
    
        # load all files ending in .prb from the records dir
        def load_records
            if File.exists?(@config[:records_dir])
                records = Dir.new(@config[:records_dir]) 
                records.entries.grep(/\.prb$/).each do |r|
                    Pdns::Runner.warn("Loading new record from #{@config[:records_dir]}/#{r}")
                    Kernel.load("#{@config[:records_dir]}/#{r}")
                end
            else
                raise("Can't find records dir #{@config[:records_dir]}")
            end
        end

        # Reads configuration from a config file, saves config in a hash @config
        def read_config(configfile, defaults)
            @config = defaults

            if File.exists?(configfile)
                File.open(configfile, "r").each do |line|
                    unless line =~ /^#|^$/
                         if (line =~ /(.+?)\s*=\s*(.+)/)
                            key = $1
                            val = $2

                            case key
                                when "logfile", "records_dir", "soa_contact", "soa_nameserver"
                                    s = key.to_sym
                                    @config[s] = val
                                when "loglevel"
                                    case val
                                        when "info"
                                            @config[:loglevel] = Logger::INFO
                                        when "warn"
                                            @config[:loglevel] = Logger::WARN
                                        when "debug"
                                            @config[:loglevel] = Logger::DEBUG
                                        when "fatal"
                                            @config[:loglevel] = Logger::FATAL
                                        when "error"
                                            @config[:loglevel] = Logger::ERROR
                                    end
                            end
                         end
                    end
                end
            else
                raise(RuntimeError, "Can't find config file: #{configfile}")
            end
        end

        # Listens on STDIN for messages from PDNS and process them
        def pdns_loop
            STDIN.each do |pdnsinput|
                pdnsinput.chomp!

                t = pdnsinput.split("\t")

                Pdns::Runner.debug("Got '#{pdnsinput}' from pdns")

                # Requests like:
                # Q foo.my.net  IN  ANY -1  1.2.3.4 0.0.0.0
                if t.size == 7
                    request = {:qname       => t[1],
                               :qclass      => t[2].to_sym,
                               :qtype       => t[3].to_sym,
                               :id          => t[4],
                               :remoteip    => t[5],
                               :localip     => t[6]}

                    if @resolver.can_answer?(request)
                        Pdns::Runner.info("Handling lookup for #{request[:qname]} from #{request[:remoteip]}")

                        answers = @resolver.do_query(request)

                        # Backends are like entire zones, so in the :record type of entry we need to have
                        # an SOA still this really is only to keep PDNS happy so we just fake it in those cases
                        if (@resolver.type(request) == :record) && (request[:qtype] != :SOA || request[:qtype] != :ANY)
                            ans = answers.fudge_soa(@config[:soa_contact], @config[:soa_nameserver])

                            Pdns::Runner.debug(ans)
                            puts ans
                        end

                        # SOA requests should not get anything else than the fudged answer above
                        if request[:qtype] != :SOA
                            answers.response.each do |ans| 
                                Pdns::Runner.debug(ans)
                                puts ans
                            end
                        end

                        Pdns::Runner.debug("END")
                        puts("END")
                    else
                       @@logger.info("Asked to serve #{request[:qname]} but don't know how")

                       # Send an END and not a FAIL, FAIL results in PDNS sending SERVFAIL to the clients
                       # which is just very retarded, #fail.
                       #
                       # The example in the docs and tarball behaves the same way.
                       puts("END")
                    end
                # requests like: AXFR 1
                elsif t.size == 2
                    Pdns::Runner.debug("END")
                    puts("END")
                else
                    Pdns::Runner.error("PDNS sent '#{pdnsinput}' which made no sense")
                    puts("FAIL")
                end
            end
        end

        # Handshakes with PDNS, if PDNS is not set up for ABI version 2 handshake will fail
        # and the backend will exit
        def handshake
            unless STDIN.gets.chomp =~ /HELO\t2/
                Pdns::Runner.error("Did not receive an ABI version 2 handshake correctly from pdns")
                puts("FAIL")
                exit
            end

            Pdns::Runner.info("Ruby PDNS backend starting with PID #{$$}")

            puts("OK\tRuby PDNS backend starting")
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
