module Pdns
    # Simple GeoIP backend that uses Net::GeoIP that only supports
    # country by_address and by_name at the moment. 
    #
    # http://geolite.maxmind.com/download/geoip/api/ruby/
    module Geoip
        @@geoip = nil

        def self.country(host)
            init_geoip unless @@geoip

            if host.match(/^\d+\.\d+\.\d+\.\d+$/)
                return @@geoip.country_code_by_addr(host)
            else
                return @@geoip.country_code_by_name(host)
            end
        end

        def self.init_geoip
            @@geoip = Net::GeoIP.open("/var/lib/GeoIP/GeoIP.dat", Net::GeoIP::TYPE_DISK)
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
