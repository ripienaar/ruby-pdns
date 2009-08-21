module Pdns
    # Simple GeoIP backend that uses Net::GeoIP that only supports
    # country by_address and by_name at the moment. 
    #
    # http://geolite.maxmind.com/download/geoip/api/ruby/
    module Geoip
        @@geoip = nil

        def self.country(host)
            begin
                init_geoip unless @@geoip

                if host.match(/^\d+\.\d+\.\d+\.\d+$/)
                    return @@geoip.country_code_by_addr(host)
                else
                    return @@geoip.country_code_by_name(host)
                end
             rescue Exception => e
                Pdns.error("Failed to do GeoIP lookup, returning nil: #{e}")
                return nil
             end
        end

        def self.init_geoip
            # get the config and set defaults
            config = Pdns.config.get_module_config("geoip")
            config["dblocation"] ? dbfile = config["dblocation"] : dbfile = "/var/lib/GeoIP/GeoIP.dat"

            Pdns.debug("Using #{dbfile} for geoip database")
            
            if File.exists? dbfile
                @@geoip = Net::GeoIP.open(dbfile, Net::GeoIP::TYPE_DISK)
            else
                raise Exception, "GeoIP data file missing: #{dbfile}"
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
