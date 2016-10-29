# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddSimpleForm < Base
      def summary
        'Add the simple_form gem'
      end

      def before_bundle
        add_gem 'simple_form'
      end

      def after_bundle
        run_generator 'simple_form:install'
        git_commit 'Install SimpleForm (rails g simple_form:install)'
      end
    end
  end
end
