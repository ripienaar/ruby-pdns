require 'test/unit'
require 'pdns'

class TC_StatsTests < Test::Unit::TestCase
    def test_if_inits_to_none
        s = Pdns::Stats.new

        assert_equal s.stats, {}
    end

    def test_if_increments_ok
        s = Pdns::Stats.new

        s.initstats("foo")
        s.recorduse("foo", 0.1)

        assert_equal s.stats, {"foo" => {:usagecount => 1, :totaltime => 0.1}}

        s.recorduse("foo", 0.1)

        assert_equal s.stats, {"foo" => {:usagecount => 2, :totaltime => 0.2}}
    end

    def test_reset
        s = Pdns::Stats.new

        s.initstats("foo")

        s.recorduse("foo", 0.1)
        s.resetrecord("foo")

        assert_equal s.stats, {"foo" => {:usagecount => 0, :totaltime => 0}}
    end

    def test_if_i_can_increment_nonexisting_record
        s = Pdns::Stats.new

        s.recorduse("foo", 0.1)

        assert_equal s.stats, {"foo" => {:usagecount => 1, :totaltime => 0.1}}
    end

    def test_yaml_dump
        s = Pdns::Stats.new

        s.recorduse("foo", 0.1)

        assert_equal YAML.load(s.stats.to_yaml), {"foo" => {:usagecount => 1, :totaltime => 0.1}}
    end

    def test_yaml_save_and_load
        s = Pdns::Stats.new
        s.recorduse("foo", 0.1)

        s.to_file("/tmp/$$.pstat")

        orig = s.stats

        s = Pdns::Stats.new
        s.load_file("/tmp/$$.pstat")

        File.delete("/tmp/$$.pstat")

        assert_equal orig, s.stats
    end

    def test_if_each_works
        s = Pdns::Stats.new

        s.recorduse("foo", 0.1)
        s.recorduse("bar", 0.1)

        records = []

        s.each do |record, stats|
            records << record
        end
            
        assert records.include?("foo")
        assert records.include?("bar")
    end

    def test_save
        Pdns.config = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        s = Pdns::Stats.new

        s.recorduse("foo", 0.1)

        s.save

        assert File.exist?("#{Pdns.config.statsdir}/#{$$}.pstat")

        File.delete("#{Pdns.config.statsdir}/#{$$}.pstat")
    end

    def test_aggregates
        Pdns.config = Pdns::Config.new("etc/pdns-ruby-backend.cfg")

        s = Pdns::Stats.new
        s.recorduse("foo", 0.1)
        s.recorduse("foo", 0.1)
        s.to_file("#{Pdns.config.statsdir}/123.pstat")
        s.reset!

        s.recorduse("foo", 0.1)
        s.recorduse("bar", 0.1)
        s.to_file("#{Pdns.config.statsdir}/124.pstat")

        s.aggregate!

        assert_equal 3, s.recordstats("foo")[:usagecount]
        assert_equal 1, s.recordstats("bar")[:usagecount]
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
