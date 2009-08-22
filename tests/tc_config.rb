require 'test/unit'
require 'pdns'

class TC_Config < Test::Unit::TestCase
    def test_config_should_not_raise_on_bogus_data
        assert_nothing_raised do
            Pdns::Config.new("etc/test_config_should_not_die_on_bogus_data.cfg")
        end
    end

    def test_config_sets_defaults
        c = Pdns::Config.new("etc/test_config_sets_defaults.cfg")

        assert_equal c.logfile, "/var/log/pdns/pipe-backend.log"
        assert_equal c.loglevel, "info"
        assert_equal c.records_dir, "/etc/pdns/records"
        assert_equal c.soa_contact, "unconfigured.ruby.pdns.server"
        assert_equal c.soa_nameserver, "unconfigured.ruby.pdns.server"
        assert_equal c.reload_interval, 60
        assert_equal c.keep_logs, 10
        assert_equal c.max_log_size, 1024000
        assert_equal c.maint_interval, 60
        assert_equal c.modules, {}
    end

    def test_config_sets_passed_values
        c = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        assert_equal c.logfile, "/dev/null"
    end

    def test_get_module_config_returns_empty_on_unknown
        c = Pdns::Config.new("etc/pdns-ruby-backend.cfg")
        
        assert_equal c.get_module_config("foo"), {}
    end

    def test_get_module_config_returns_expected
        c = Pdns::Config.new("etc/pdns-ruby-backend.cfg")
        m = c.get_module_config("geoip")

        assert_equal m["dblocation"], "/var/lib/GeoIP/GeoIP.dat"
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
