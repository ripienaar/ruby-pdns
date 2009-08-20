module Pdns
    class Log
        @logger = nil

        def initialize
            config = Pdns::config

            @logger = Logger.new(config.logfile, config.keep_logs, config.max_log_size)

            case config.loglevel
                when "info"
                    @logger.level = Logger::INFO
                when "warn"
                    @logger.level = Logger::WARN
                when "debug"
                    @logger.level = Logger::DEBUG
                when "fatal"
                    @logger.level = Logger::FATAL
                when "error"
                    @logger.level = Logger::ERROR
            end
        end

        # do some fancy logging with caller information etc
        def log(severity, msg)
            from = File.basename(caller[1])
            @logger.add(severity) { "#{$$} #{from}: #{msg}" }
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
