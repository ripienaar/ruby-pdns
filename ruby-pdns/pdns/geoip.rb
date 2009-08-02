module Pdns
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
