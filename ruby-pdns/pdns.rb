require 'logger'
require 'net/geoip'

class Array
    def shuffle!
        size.downto(1) { |n| push delete_at(rand(n)) }
        self
    end
end

# Top module for pdns backends, record code will execute at this
# level so functions like 'country' need to be created here as
# class methods and should typically just wrap around other classes
# that does the hard work.
module Pdns
    class UnknownQueryType < RuntimeError; end
    class UnknownQueryClass < RuntimeError; end
    class InvalidTTL < RuntimeError; end
    class InvalidID < RuntimeError; end

    autoload :Resolvers, "pdns/resolvers.rb"
    autoload :Response, "pdns/response.rb"
    autoload :Geoip, "pdns/geoip.rb"
    autoload :Runner, "pdns/runner.rb"

    # Register a new code block to answer a specific
    # resource record
    def self.newrecord(name, options = {}, &block)
        Pdns::Resolvers.add_resolver(name, options, &block)
    end

    # Does a country lookup using Pdns::Geoip can handle hostnames
    # or IP addresses
    def self.country(host)
        Pdns::Geoip.country(host)
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
