# frozen_string_literal: true
module ThreddedCreateApp
  class Generator
    include ThreddedCreateApp::Logging

    def self.run(options)
      new(options).run
    end

    def initialize(app_name:)
      @app_name = app_name
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
