require 'test/unit'
require 'pdns'

class TC_ResponseTests < Test::Unit::TestCase
    def test_valid_qtype_checks
        r = Pdns::Response.new("test_valid_qtype_checks")

        assert_raise Pdns::UnknownQueryType do
            r.qtype :FOO    
        end
    end

    def test_valid_qclass_checks
        r = Pdns::Response.new("test_valid_qclass_checks")

        assert_raise Pdns::UnknownQueryClass do
            r.qclass :FOO    
        end
    end

    def test_valid_id_checks
        r = Pdns::Response.new("test_valid_id_checks")

        assert_raise Pdns::InvalidID do
            r.id "a"
        end
    end

    def test_valid_ttl_checks
        r = Pdns::Response.new("test_valid_ttl_checks")

        assert_raise Pdns::InvalidTTL do
            r.ttl "a"
        end
    end

    def test_valid_shuffle_checks
        r = Pdns::Response.new("test_valid_shuffle_checks")

        assert_raise Pdns::InvalidShuffle do
            r.shuffle "foo"
        end
    end

    def test_record_defaults 
        r = Pdns::Response.new("foo")

        h = r.raw_response

        assert_equal h[:qtype], :A
        assert_equal h[:qclass], :IN
        assert_equal h[:ttl], 3600
        assert_equal h[:id], 1
        assert_equal h[:shuffle], true
        assert_equal h[:qname], "foo"
    end

    def test_single_param_content
        r = Pdns::Response.new("foo")

        r.content "127.0.0.1"
        assert_equal r.raw_response[:content][0], "127.0.0.1"
    end

    def test_two_param_content
        r = Pdns::Response.new("foo")
        r.content :CNAME, "www.foo.com"

        assert_match /DATA\tfoo\tIN\tCNAME\t3600\t1\twww.foo.com/, r.response[0]
    end

    def test_three_param_content
        r = Pdns::Response.new("foo")
        r.content 300, :CNAME, "www.foo.com"

        assert_match /DATA\tfoo\tIN\tCNAME\t300\t1\twww.foo.com/, r.response[0]
    end

    def test_multiple_content
        r = Pdns::Response.new("foo")

        r.content "1.2.3.4"
        r.content "5.6.7.8"

        assert_equal r.raw_response[:content][0], "1.2.3.4"
        assert_equal r.raw_response[:content][1], "5.6.7.8"
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
