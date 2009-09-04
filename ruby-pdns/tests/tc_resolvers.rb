require 'test/unit'
require 'pdns'

class TC_ResolversTests < Test::Unit::TestCase
    def test_if_record_load
        resolvers = Pdns::Resolvers.new
        Pdns::Resolvers.empty!

        Kernel.load("records/test_if_record_load.prb")

        assert resolvers.can_answer?({:qname => "test_if_record_load.ruby-pdns.org"})
    end

    def test_if_empty_clears_records
        resolvers = Pdns::Resolvers.new
        Kernel.load("records/test_if_record_load.prb")

        Pdns::Resolvers.empty!
        assert_equal resolvers.can_answer?({:qname => "ttest_if_empty_clears_records.ruby-pdns.org"}), false
    end

    def test_if_handles_mixed_case_as_lower
        resolvers = Pdns::Resolvers.new
        Pdns::Resolvers.empty!

        Kernel.load("records/test_if_handles_mixed_case_as_lower.prb")

        assert resolvers.can_answer?({:qname => "TeSt_If_handles_Mixed_case_as_lower.ruby-pdns.org"})
    end

    def test_if_stats_increment
        resolvers = Pdns::Resolvers.new
        Pdns::Resolvers.empty!

        Kernel.load("records/test_if_stats_increment.prb")

        result = resolvers.do_query({:qname     => "test_if_stats_increment.ruby-pdns.org",
                                     :qclass    => :IN,
                                     :qtype     => :ANY,
                                     :id        => 1,
                                     :localip   => "127.0.0.2",
                                     :remoteip  => "207.192.75.148" })
        
        assert_equal resolvers.stats.recordstats("test_if_stats_increment.ruby-pdns.org")[:usagecount], 1
        assert_in_delta 0.1, resolvers.stats.recordstats("test_if_stats_increment.ruby-pdns.org")[:totaltime], 0.5
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
