# frozen_string_literal: true
module ThreddedCreateApp
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
