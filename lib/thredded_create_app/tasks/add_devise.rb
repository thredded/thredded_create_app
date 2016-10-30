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
        setup_after_sign_in_behaviour
        git_commit 'Setup Devise'
      end

      private

      def setup_after_sign_in_behaviour
        inject_into_file 'app/controllers/application_controller.rb',
                         after:   /protect_from_forgery.*\n/,
                         content: <<-'RUBY'
  # devise
  before_filter :store_current_location, unless: :devise_controller?

  private

  # devise
  def store_current_location
    store_location_for(:user, request.url)
  end

  # devise
  def after_sign_out_path_for(resource)
    request.referrer || root_path
  end
        RUBY
      end

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
