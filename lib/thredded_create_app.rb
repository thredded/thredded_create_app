# frozen_string_literal: true
require 'thredded_create_app/version'
require 'thredded_create_app/logging'
require 'thredded_create_app/generator'

module ThreddedCreateApp
  class << self
    attr_writer :verbose
    def verbose?
      @verbose
    end
  end

  # When this type of error is caught:
  # 1. show error message of the backtrace
  # 2. exit with non-zero exit code
  class CommandError < StandardError
    # rubocop:disable Style/OptionalArguments
    def initialize(error = nil, message)
      super(message)
      set_backtrace error.backtrace if error
    end
    # rubocop:enable Style/OptionalArguments
  end
end
