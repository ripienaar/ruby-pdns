require 'logger'
require 'net/geoip'

# Extend the standard Array with certain abilities that would be useful to our situation
class Array
    # Randomly shuffles the contents of the array
    def shuffle!
        size.downto(1) { |n| push delete_at(rand(n)) }
        self
    end

    # Weighted random stuff from http://snippets.dzone.com/posts/show/898
    #
    # Chooses a random array element from the receiver based on the weights
    # provided. If _weights_ is nil, then each element is weighed equally.
    # 
    #   [1,2,3].random          #=> 2
    #   [1,2,3].random          #=> 1
    #   [1,2,3].random          #=> 3
    #
    # If _weights_ is an array, then each element of the receiver gets its
    # weight from the corresponding element of _weights_. Notice that it
    # favors the element with the highest weight.
    #
    #   [1,2,3].random([1,4,1]) #=> 2
    #   [1,2,3].random([1,4,1]) #=> 1
    #   [1,2,3].random([1,4,1]) #=> 2
    #   [1,2,3].random([1,4,1]) #=> 2
    #   [1,2,3].random([1,4,1]) #=> 3
    #
    # If _weights_ is a symbol, the weight array is constructed by calling
    # the appropriate method on each array element in turn. Notice that
    # it favors the longer word when using :length.
    #
    #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
    #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "dog"
    #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
    #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
    #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "cat"
    def random(weights=nil)
        return random(map {|n| n.send(weights)}) if weights.is_a? Symbol
      
        weights ||= Array.new(length, 1.0)
        total = weights.inject(0.0) {|t,w| t+w}
        point = rand * total
      
        zip(weights).each do |n,w|
            return n if w >= point
            point -= w
        end
    end
    
    # Generates a permutation of the receiver based on _weights_ as in
    # Array#random. Notice that it favors the element with the highest
    # weight.
    #
    #   [1,2,3].randomize           #=> [2,1,3]
    #   [1,2,3].randomize           #=> [1,3,2]
    #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
    #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
    #   [1,2,3].randomize([1,4,1])  #=> [1,2,3]
    #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
    #   [1,2,3].randomize([1,4,1])  #=> [3,2,1]
    #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
    def randomize(weights=nil)
        return randomize(map {|n| n.send(weights)}) if weights.is_a? Symbol
      
        weights = weights.nil? ? Array.new(length, 1.0) : weights.dup
      
        # pick out elements until there are none left
        list, result = self.dup, []
        until list.empty?
            # pick an element
            result << list.random(weights)
            # remove the element from the temporary list and its weight
            weights.delete_at(list.index(result.last))
            list.delete result.last
        end
      
        result
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
    def self.newrecord(name, options = {}, &block)
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
