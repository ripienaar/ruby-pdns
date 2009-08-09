module Pdns
    class Logger
        @logger = nil

        def initialize
            config = Pdns::config

            @logger = Logger.new(config.logfile, config.keep_logs, config.max_log_size)
            @logger.level = config.loglevel
        end

        # do some fancy logging with caller information etc
        def log(severity, msg)
            @@logger.add(severity) { "#{$$} #{caller[3]}: #{msg}" }
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
