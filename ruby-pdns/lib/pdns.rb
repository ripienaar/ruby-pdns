require 'logger'
require 'net/geoip'
require 'pdns/array.rb'
require 'yaml'

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
    class RecordCallError < RuntimeError; end

    autoload :Resolvers, "pdns/resolvers.rb"
    autoload :Response, "pdns/response.rb"
    autoload :Geoip, "pdns/geoip.rb"
    autoload :Runner, "pdns/runner.rb"
    autoload :Config, "pdns/config.rb"
    autoload :Log, "pdns/log.rb"
    autoload :Stats, "pdns/stats.rb"
    autoload :Extdata, "pdns/extdata.rb"

    # should have a copy of Pdns::Config
    @@config = nil

    # Instance of Pdns::Log
    @@logger = nil

    # Instance of Pdns::Extdata
    @@extdata = nil

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

    # Saves the external data handler, should be an instance of Pdns::Extdata
    def self.extdata=(extdata)
        @@extdata = extdata
    end

    # Gives access to the Pdns::Extdata instance
    def self.extdata
        @@extdata
    end

    # Returns the previously saved instance of Pdns::Config
    def self.config
        @@config
    end

    # Fetches a value from the external data for the current 
    def self.data(key, default)
        cur = Pdns::Resolvers.active_record
        debug("Looking up key #{key} for record #{cur}")
        @@extdata.data(cur, key, default)
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

    # returns the current loglevel
    def self.loglevel
        @@logger.logger.level
    end
end
# vi:tabstop=4:expandtab:ai:filetype=ruby
