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
    #    geoipdb = /var/lib/GeoIP/GeoIP.dat
    #
    class Config
        attr_reader :logfile, :loglevel, :records_dir, :soa_contact, :soa_nameserver, :reload_interval, :keep_logs, :max_log_size, :geoipdb, :maint_interval

        def initialize(configfile)
            @logfile = "/var/log/pdns/pipe-backend.log"
            @loglevel = "info"
            @records_dir = "/etc/pdns/pipe_records"
            @soa_contact = "unconfigured.ruby.pdns.server"
            @soa_nameserver = "unconfigured.ruby.pdns.server"
            @reload_interval = 60
            @keep_logs = 10
            @max_log_size = 1024000
            @maint_interval = 60
            @geoipdb = "/var/lib/GeoIP/GeoIP.dat"


            if File.exists?(configfile)
                File.open(configfile, "r").each do |line|
                    unless line =~ /^#|^$/
                        if (line =~ /(.+?)\s*=\s*(.+)/)
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
                                when "geoipdb"
                                    @geoipdb = val
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
    end
end

# vi:tabstop=4:expandtab:ai
