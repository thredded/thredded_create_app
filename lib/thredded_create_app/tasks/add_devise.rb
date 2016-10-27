# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddDevise < Base
      def before_bundle
        add_gem 'devise'
        add_gem 'devise-i18n'
      end

      def after_bundle
        run_generator 'devise:install'
        run_generator 'devise User'

        git_commit 'Setup Devise'
      end
    end
  end
end
