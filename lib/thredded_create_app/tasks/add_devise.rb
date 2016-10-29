# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddDevise < Base
      def summary
        'Add devise with I18n and configure a User model'
      end

      def before_bundle
        add_gem 'devise'
        add_gem 'devise-i18n'
      end

      def after_bundle
        run_generator 'devise:install'
        run_generator 'devise User'
        setup_views
        git_commit 'Setup Devise'
      end

      private

      def setup_views
        run_generator 'devise:i18n:views -v sessions registrations'
        # Make the views render-able outside Devise controllers
        %w(app/views/devise/registrations/new.html.erb
           app/views/devise/registrations/edit.html.erb
           app/views/devise/sessions/new.html.erb
           app/views/devise/shared/_links.html.erb).each do |path|
          replace path, 'resource_name', ':user'
          replace path, 'resource', ':user'
          replace path, 'resource_class', 'User', optional: true
          replace path, 'devise_mapping', 'Devise.mappings[:user]',
                  optional: true
        end
      end
    end
  end
end
