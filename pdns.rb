require 'logger'
require 'net/geoip'
require 'pdns/array.rb'

# Top module for pdns backends, record code will execute at this
# level so functions like 'country' need to be created here as
# class methods and should typically just wrap around other classes
# that does the hard work.
module Pdns
    class UnknownQueryType < RuntimeError; end
    class UnknownQueryClass < RuntimeError; end
    class InvalidTTL < RuntimeError; end
    class InvalidID < RuntimeError; end
    class InvalidShuffle < RuntimeError; end
    class UnknownRecord < RuntimeError; end

    autoload :Resolvers, "pdns/resolvers.rb"
    autoload :Response, "pdns/response.rb"
    autoload :Geoip, "pdns/geoip.rb"
    autoload :Runner, "pdns/runner.rb"
    autoload :Config, "pdns/config.rb"
    autoload :Log, "pdns/log.rb"

    # should have a copy of Pdns::Config
    @@config = nil

    # Instance of Pdns::Log
    @@logger = nil

    # Register a new code block to answer a specific
    # resource record
    def self.newrecord(name, &block)
        options = { :type => :record }

        Pdns::Resolvers.add_resolver(name, options, &block)
    end

    # Does a country lookup using Pdns::Geoip can handle hostnames
    # or IP addresses
    def self.country(host)
        Pdns::Geoip.country(host)
    end

    # Saves the config, should be an instance of Pdns::Config
    def self.config=(config)
        @@config = config
    end

    # Returns the previously saved instance of Pdns::Config
    def self.config
        @@config
    end

    ## methods other classes can use to acces our logger
    # logs at level INFO
    def self.info(msg)
        @@logger = Pdns::Log.new unless @@logger

        @@logger.log(Logger::INFO, msg)
    end

    # logs at level WARN
    def self.warn(msg)
        @@logger = Pdns::Log.new unless @@logger

        @@logger.log(Logger::WARN, msg)
    end

    # logs at level DEBUG
    def self.debug(msg)
        @@logger = Pdns::Log.new unless @@logger

        @@logger.log(Logger::DEBUG, msg)
    end

    # logs at level FATAL
    def self.fatal(msg)
        @@logger = Pdns::Log.new unless @@logger

        @@logger.log(Logger::FATAL, msg)
    end

    # logs at level ERROR
    def self.error(msg)
        @@logger = Pdns::Log.new unless @@logger

        @@logger.log(Logger::ERROR, msg)
    end
end
# vi:tabstop=4:expandtab:ai:filetype=ruby
