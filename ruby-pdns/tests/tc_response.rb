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
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
