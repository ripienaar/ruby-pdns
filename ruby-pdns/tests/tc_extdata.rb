require 'test/unit'
require 'pdns'

class TC_ExtdataTests < Test::Unit::TestCase
    def test_if_data_loads
        Pdns.config = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        d = Pdns::Extdata.new

        assert_equal 1254850881, d.data(:foo, :created)
    end

    def test_if_default_works
        Pdns.config = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        d = Pdns::Extdata.new

        assert_equal 1, d.data(:foo, :foo, 1)
        assert_equal 1, d.data(:bar, :foo, 1)
    end

    def test_all_data
        Pdns.config = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        d = Pdns::Extdata.new

        assert_equal 20, d.all_data(:foo)[:data][:webserver_b_load]
        assert_equal Hash.new, d.all_data(:bar)
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
