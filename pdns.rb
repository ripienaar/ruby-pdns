class Array
    def shuffle!
        size.downto(1) { |n| push delete_at(rand(n)) }
        self
    end
end

module Pdns
    class UnknownQueryType < RuntimeError; end
    class UnknownQueryClass < RuntimeError; end
    class InvalidTTL < RuntimeError; end
    class UnknownRecord < RuntimeError; end

    autoload :Resolvers, "pdns/resolvers.rb"
    autoload :Response, "pdns/response.rb"

    # Register a new code block to answer a specific
    # resource record
    def self.newrecord(name, options = {}, &block)
        Pdns::Resolvers.add_resolver(name, options, &block)
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
