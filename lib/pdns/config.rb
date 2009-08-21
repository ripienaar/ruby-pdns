module Pdns
    # Simple class to handle the configuring of the framework.
    #
    # At present config files can look like this, showing defaults:
    #
    #    logfile = /var/log/pdns/pipe-backend.log
    #    loglevel = info|error|warn|fatal|debug
    #    records_dir = /etc/pdns/records
    #    soa_contact = unconfigured.ruby.pdns.server
    #    soa_nameserver = unconfigured.ruby.pdns.server
    #    reload_interval = 60
    #    keep_logs = 10
    #    max_log_size = 1024000
    #
    # Additionally freeform config can be set for modules, these need to be handled by the modules but
    # config lines like:
    #    geoip.dblocation = /var/lib/GeoIP/GeoIP.dat
    #
    # Can be retrieved with get_module_config["geoip"] which will then be a hash, it's up to the 
    # modules to sanity check these config vals
    class Config
        attr_reader :logfile, :loglevel, :records_dir, :soa_contact, :soa_nameserver, :reload_interval, :keep_logs, :max_log_size, :geoipdb, :maint_interval

        def initialize(configfile)
            @logfile = "/var/log/pdns/pipe-backend.log"
            @loglevel = "info"
            @records_dir = "/etc/pdns/records"
            @soa_contact = "unconfigured.ruby.pdns.server"
            @soa_nameserver = "unconfigured.ruby.pdns.server"
            @reload_interval = 60
            @keep_logs = 10
            @max_log_size = 1024000
            @maint_interval = 60
            @modules = {}


            if File.exists?(configfile)
                File.open(configfile, "r").each do |line|
                    unless line =~ /^#|^$/
                        if (line =~ /(.+?)\.(.+?)\s*=\s*(.+)/)
                            mod = $1
                            key = $2
                            val = $3

                            @modules[mod] = {} unless @modules[mod]
                            @modules[mod][key] = val

                        elsif (line =~ /(.+?)\s*=\s*(.+)/)
                            key = $1
                            val = $2

                            case key
                                when "logfile"
                                    @logfile = val
                                when "records_dir"
                                    @records_dir = val
                                when "soa_contact"
                                    @soa_contact = val
                                when "soa_nameserver"
                                    @soa_nameserver = val
                                when "reload_interval"
                                    @reload_interval = val.to_i
                                when "keep_logs"
                                    @keep_logs = val.to_i
                                when "max_log_size"
                                    @max_log_size = val.to_i
                                when "maint_interval"
                                    @maint_interval = val.to_i
                                when "loglevel"
                                    @loglevel = val
                                else
                                    Pdns.error("Unknown config parameter #{key}")
                            end
                        end
                    end
                end
            end

            Pdns.config = self
            self
        end

        # Retrieves config for just a specific module, returns {} if unset
        def get_module_config(mod)
            if @modules[mod]
                return @modules[mod]
            else
                return {}
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
