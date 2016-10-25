# frozen_string_literal: true
require 'term/ansicolor'
module ThreddedCreateApp
  module Logging
    def log_verbose(message = nil)
      return unless ThreddedCreateApp.verbose?
      log_stderr Term::ANSIColor.bright_blue(message || yield)
    end

    def log_warn(message)
      log_stderr Term::ANSIColor.yellow("#{program_name}: [WARN] #{message}")
    end

    def log_error(message)
      log_stderr Term::ANSIColor.red Term::ANSIColor.bold(
        "#{program_name}: #{message}"
      )
    end

    def log_stderr(*args)
      STDERR.puts(*args)
    end

    def program_name
      @program_name ||= File.basename($PROGRAM_NAME)
    end
  end
end
