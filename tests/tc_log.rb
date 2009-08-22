require 'test/unit'
require 'pdns'

class TC_LogTests < Test::Unit::TestCase
    def test_if_logger_set_default_on_error
        c = nil
        l = nil

        assert_nothing_raised do
            c = Pdns::Config.new("etc/test_if_logger_set_default_on_error.cfg")
            l = Pdns::Log.new
        end

        assert_equal l.logger.level, Logger::INFO
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
