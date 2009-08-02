module Pdns
    # The workhorse class for the framework, speads directly to PDNS
    # via STDIN and STDOUT. 
    #
    # It requires your PDNS to speak ABI version 2.
    class Runner
        @logger = nil

        def initialize(configfile = "/etc/pdns/pipe-backend.cfg")
            STDOUT.sync = true
            STDIN.sync = true
            STDERR.sync = true
        
            read_config(configfile, :logfile => "/var/log/pdns/pipe-backend.log",
                                    :loglevel => "info",
                                    :records_dir => "/etc/pdns/pipe_records")

            @resolver = Pdns::Resolvers.new

            @logger = Logger.new(@config[:logfile], 10, 102400)
            @logger.level = @config[:loglevel]

            handshake

            load_records

            pdns_loop
        end

        private
        def load_records
            if File.exists?(@config[:records_dir])
                records = Dir.new(@config[:records_dir]) 
                records.entries.grep(/^[^.]/).each do |r|
                    @logger.info("Loading new record from #{r}")
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
                                when "logfile", "records_dir"
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

                @logger.debug("Got '#{pdnsinput}' from pdns")

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
                # requests like: AXFR 1
                elsif t.size == 2
                    @logger.debug("END")
                    puts("END")
                else
                    @logger.error("PDNS sent '#{pdnsinput}' which made no sense")
                    puts("FAIL")
                end
            end
        end

        # Handshakes with PDNS, if PDNS is not set up for ABI version 2 handshake will fail
        # and the backend will exit
        def handshake
            unless STDIN.gets.chomp =~ /HELO\t2/
                @logger.error("Did not receive an ABI version 2 handshake correctly from pdns")
                puts("FAIL")
                exit
            end

            @logger.info("Ruby PDNS backend starting with PID #{$$}")

            puts("OK\tRuby Bayes PDNS backend starting")
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
