# frozen_string_literal: true
module ThreddedCreateApp
  class Generator
    include ThreddedCreateApp::Logging

    def initialize(**options)
      @options = options
    end

    def summary
      '* stuff'
    end

    def run
      log_verbose "Started: #{inspect}"
      # Create DB users
      # Run `rails new`
      # Add and install gems
      # Configure devise
      # Configure thredded
      # Copy templates
      # Bundle
      # Start server
      # Done
    end
  end
end
