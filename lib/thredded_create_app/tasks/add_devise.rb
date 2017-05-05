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
        replace 'config/initializers/filter_parameter_logging.rb',
                ':password',
                ':password, :password_confirmation'
        run_generator 'devise:install'
        run_generator 'devise User'
        setup_views
        setup_emails
        setup_after_sign_in_behaviour
        git_commit 'Setup Devise'
      end

      private

      def setup_after_sign_in_behaviour
        inject_into_file 'app/controllers/application_controller.rb',
                         after:   /protect_from_forgery.*\n/,
                         content: <<-'RUBY'

  before_action :store_current_location, unless: :devise_controller?
  helper_method :back_url

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def after_sign_out_path_for(resource)
    stored_location_for(:user) || (respond_to?(:root_path) ? root_path : thredded.root_path)
  end

  def back_url
    session[:user_return_to] || (respond_to?(:root_path) ? root_path : thredded.root_path)
  end
        RUBY
      end

      def setup_views
        run_generator 'devise:i18n:views -v sessions registrations'
        # Replace the back link with the correct URL
        replace 'app/views/devise/registrations/edit.html.erb',
                ', :back %>', ', back_url %>'
        # Make the views render-able outside Devise controllers
        %w[app/views/devise/sessions/new.html.erb
           app/views/devise/shared/_links.html.erb].each do |path|
          replace path, 'resource_class', 'User', optional: true
          replace path, /resource_name(?!:)/, ':user'
          replace path, /resource(?!:)/, ':user', optional: true
          replace path, 'devise_mapping', 'Devise.mappings[:user]',
                  optional: true
        end
      end

      def setup_emails
        replace 'config/initializers/devise.rb',
                /# config\.parent_mailer = .*/,
                <<~'RUBY'.chomp
                  config.parent_mailer = 'ApplicationMailer'
                RUBY
        replace 'config/initializers/devise.rb',
                /( *)config\.mailer_sender = .*/,
                '\1' + <<~'RUBY'.chomp
                  config.mailer_sender = %("#{I18n.t('brand.name')}" <#{Settings.email_sender}>)
                RUBY
      end
    end
  end
end
