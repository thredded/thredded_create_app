# frozen_string_literal: true

require 'rainbow'
module ThreddedCreateApp
  module Logging
    def log_verbose(message = nil)
      return unless verbose?
      log_stderr Rainbow(message || yield).magenta.bright
    end

    def log_command(message)
      log_stderr Rainbow(message).bright
    end

    def log_info(message)
      log_stderr Rainbow(message).blue.bright
    end

    def log_warn(message)
      log_stderr Rainbow("#{program_name}: [WARN] #{message}").yellow
    end

    def log_error(message)
      log_stderr Rainbow("#{program_name}: #{message}").red.bold
    end

    def log_stderr(*args)
      STDERR.puts(*args)
    end

    def program_name
      @program_name ||= File.basename($PROGRAM_NAME)
    end
  end
end
