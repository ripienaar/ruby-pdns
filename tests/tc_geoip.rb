require 'test/unit'
require 'pdns'
require 'pp'

class TC_GeoIPTests < Test::Unit::TestCase
    def test_if_country_code_is_right
        pdns = Pdns::Runner.new("etc/pdns-ruby-backend.cfg", "tester")

        assert_equal "GB", Pdns.country("193.201.200.202")
    end

    def test_if_no_data_file_returns_nil
        pdns = Pdns::Runner.new("etc/test_if_no_data_file_returns_nil.cfg", "tester")

        # Force reload the geoip object, fails and so it nulls it
        # this gets the country call to do the real / right logic
        begin
            Pdns::Geoip.init_geoip
        rescue Exception => e
        end

        assert_equal nil, Pdns.country("193.201.200.202")
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
