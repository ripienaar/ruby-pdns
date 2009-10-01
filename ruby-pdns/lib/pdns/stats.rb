require 'yaml'
require 'find'

module Pdns
    class Stats
        attr_reader :stats

        def initialize
            reset!
        end

        # sets the stats for a record to 0
        def resetrecord(record)
            @stats[record] = newstat
        end

        # resets all stats to nil
        def reset!
            @stats = {}
	    @stats["ruby-pdns-totals"] = newstat
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

            @stats["ruby-pdns-totals"][:usagecount] += 1
            @stats["ruby-pdns-totals"][:totaltime] += time
        end

        # Returns the stats for a record or an empty record if its not set
        def recordstats(record)
            initstats(record) unless @stats[record]

            @stats[record] ? @stats[record] : newstat
        end

        # Returns the totals for all records usage
        def totalstats
            @stats["ruby-pdns-totals"]
        end

        # figures out if stats for a given record exist
        def include_record?(record)
            @stats.include?(record)
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
                f.write(to_yaml)
            end

            Pdns.debug("Saved stats to #{filename}")
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

        # Utility to find all stats in the stats dir and return a single hash
        # that aggregates all the found stats into one variable
        def aggregate
            totals = {}

            Find.find(Pdns.config.statsdir) do |path| 
                if path.match(/\/\d+.pstat$/)
                    statage = Time.now.to_i - File.new(path).mtime.to_i

                    # sleep a bit if the file is very new to give the writer 
                    # time to update the file properly
                    sleep 1 if statage < 2

                    stat = {}

                    # we only care for files newer than maint_interval + 30s, delete older
                    # ones to avoid importing really old stats from children that
                    # has been killed off by pdns
                    if statage < (Pdns.config.maint_interval + 30)
                        Pdns.debug("Parsing stats in #{path}")
                        load_file(path) 

                        each do |record, rs|
                            totals[record] = {:usagecount => 0, :totaltime => 0} unless totals[record]
                            totals[record][:usagecount] += rs[:usagecount]
                            totals[record][:totaltime] += rs[:totaltime]
                        end
                    else
                        Pdns.info("Deleting old data in #{path}")
                        File.delete(path)
                    end
                end
            end

            totals
        end

        # Uses the aggregate function to get a sum of all stats and then overwrite the stats in the 
        # object instance with the aggregate data effectively turning the current object into a access
        # method to the aggregate data so to_file, each etc can be used on it.
        def aggregate!
            @stats = aggregate
        end

        private
        # Creates an empty stats hash
        def newstat
            {:usagecount => 0, :totaltime => 0}
        end
    end
end

# vi:tabstop=4:expandtab:ai
