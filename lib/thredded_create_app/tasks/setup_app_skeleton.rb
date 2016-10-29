# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class SetupAppSkeleton < Base
      def summary
        'Setup basic app navigation and styles'
      end
    end
  end
end
