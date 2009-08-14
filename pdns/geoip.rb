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
            if File.exists? Pdns.config.geoipdb
                @@geoip = Net::GeoIP.open(Pdns.config.geoipdb, Net::GeoIP::TYPE_DISK)
            else
                raise Exception, "GeoIP data file missing: #{Pdns.config.geoipdb}"
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
