require 'yaml'

module Pdns
    class Stats
        attr_reader :stats

        def initialize
            @stats = {}
        end

        # sets the stats for a record to 0
        def resetrecord(record)
            @stats[record] = newstat
        end

        # sets the stats for a record to 0 only if it doesn't exist already.
        # You'd call this each time a record gets loaded from disk to either
        # initialize it to 0 or to just do nothing.  You dont _have_ to call
        # this but it helps dumping sane stats for records that were never
        # lookuped up by a client yet
        def initstats(record)
            resetrecord(record) unless @stats[record]
        end

        # Add 1 to the usage count for a record and increment the total time
        # spent service a record
        def recorduse(record, time)
            initstats(record) unless @stats[record]

            @stats[record][:usagecount] += 1
            @stats[record][:totaltime] += time
        end

        # Returns the stats for a record or an empty record if its not set
        def recordstats(record)
            initstats(record) unless @stats[record]

            @stats[record] ? @stats[record] : newstat
        end

        # Returns a YAML representation of the current stats
        def to_yaml
            YAML.dump(@stats)
        end

        # Utility method that uses to_file to save the stats in the stats dir
        # 
        # Will raise exceptions if anything fails
        def save
            to_file("#{Pdns.config.statsdir}/#{$$}.pstat")
        end

        # Saves stats to a file will throw exceptions if the file cannot be written.
        # 
        # Will raise exceptions if anything fails
        def to_file(filename)
            File.open(filename, 'w') do |f|
                YAML.dump(@stats, f)
            end
        end

        # Reads stats from a file
        # 
        # Will raise exceptions if anything fails
        def load_file(filename)
            @stats = YAML.load_file(filename)
        end

        # Calls a block with each known records and its stats
        def each
            @stats.each_key do |k|
                yield(k, @stats[k])
            end
        end

        private
        # Creates an empty stats hash
        def newstat
            {:usagecount => 0, :totaltime => 0}
        end
    end
end

# vi:tabstop=4:expandtab:ai
