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
        setup_controllers
        setup_views
        setup_emails
        setup_after_sign_in_behaviour
        copy 'add_devise/spec/features/devise_spec.rb',
             'spec/features/devise_spec.rb'
        git_commit 'Setup Devise'
      end

      private

      def setup_after_sign_in_behaviour
        inject_into_file 'app/controllers/application_controller.rb',
                         after:   /::Base\n(  protect_from_forgery.*\n)?/,
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

      def setup_controllers
        copy 'add_devise/sessions_controller.rb',
             'app/controllers/users/sessions_controller.rb'
        replace 'config/routes.rb',
                'devise_for :users',
                <<~'RUBY'.chomp
                  devise_for :users,
                             skip: %i[sessions],
                             controllers: {
                               sessions: 'users/sessions',
                             },
                             path_names: { sign_up: 'register' }
                  devise_scope :user do
                    get 'sign-in', to: 'users/sessions#new', as: :new_user_session
                    post 'sign-in', to: 'users/sessions#create', as: :user_session
                    match 'sign-out', to: 'users/sessions#destroy', as: :destroy_user_session,
                                      via: Devise.mappings[:user].sign_out_via
                  end
                RUBY
      end

      def setup_views
        # Generate all devise views that have forms, so that they use the
        # app form template (e.g. simple_form).
        run_generator 'devise:i18n:views -v confirmations passwords' \
                      ' registrations sessions unlocks'
        # Replace the back link with the correct URL
        replace 'app/views/devise/registrations/edit.html.erb',
                ', :back %>', ', back_url %>'
        # Remove "Password confirmation" from sign up.
        # See https://github.com/plataformatec/devise/wiki/Disable-password-confirmation-during-registration
        replace 'app/views/devise/registrations/new.html.erb',
                "    <%= f.input :password_confirmation, required: true %>\n",
                ''
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
