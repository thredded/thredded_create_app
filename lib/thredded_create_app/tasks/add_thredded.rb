# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddThredded < Base
      def summary
        'Add and setup Thredded with a User model'
      end

      def before_bundle
        add_gem 'thredded',
                **(ENV['LOCAL_THREDDED'] ? { path: ENV['LOCAL_THREDDED'] } : {})
      end

      def after_bundle # rubocop:disable Metrics/AbcSize
        install_thredded
        git_commit 'Install thredded (rails g thredded:install)'
        add_thredded_routes
        copy 'add_thredded/thredded.en.yml', 'config/locales/thredded.en.yml'
        set_thredded_layout
        configure_thredded_controller
        add_thredded_styles
        add_thredded_javascripts
        copy 'add_thredded/spec/features/thredded_spec.rb',
             'spec/features/thredded_spec.rb'
        git_commit 'Configure Thredded (routes, assets, behaviour, tests)'
        add_admin_column_to_users
        git_commit 'Add the admin column to users'
        setup_thredded_emails
        git_commit 'Configure Thredded emails and email styles with Roadie'
        configure_rails_email_preview
        git_commit 'Configure RailsEmailPreview with Thredded and Roadie'
        run 'bundle exec rails thredded:install:emoji'
        git_commit 'Copied emoji to public/emoji'
      end

      private

      def install_thredded
        run_generator 'thredded:install'
        run 'bundle exec rails thredded:install:migrations' \
            "#{' --quiet' unless verbose?}"
      end

      def add_thredded_routes
        add_route "mount Thredded::Engine => '/forum'"
      end

      def set_thredded_layout
        replace 'config/initializers/thredded.rb',
                "Thredded.layout = 'thredded/application'",
                "Thredded.layout = 'application'"
      end

      def configure_thredded_controller
        copy 'add_thredded/thredded_initializer_controller.rb',
             'config/initializers/thredded.rb',
             mode: 'a'
      end

      def add_thredded_styles
        copy 'add_thredded/_thredded-variables.scss',
             'app/assets/stylesheets/_thredded-variables.scss'
        copy 'add_thredded/_thredded-custom.scss',
             'app/assets/stylesheets/_thredded-custom.scss'
        File.write 'app/assets/stylesheets/_deps.scss', <<~SCSS, mode: 'a'
          @import "thredded-custom";
        SCSS
      end

      def add_thredded_javascripts
        copy 'add_thredded/myapp_thredded.js',
             "app/assets/javascripts/#{app_name}_thredded.js"
      end

      def add_admin_column_to_users
        add_migration 'add_admin_to_users', content: <<~RUBY
          def change
            add_column :users, :admin, :boolean, null: false, default: false
          end
        RUBY
      end

      def setup_thredded_emails
        File.write 'app/assets/stylesheets/email.scss', <<~'SCSS', mode: 'a'
          @import "variables";
          @import "thredded-variables";
          @import "thredded/email";
        SCSS

        replace 'config/initializers/thredded.rb',
                /# Thredded\.parent_mailer = .*/,
                "Thredded.parent_mailer = 'ApplicationMailer'"
        replace 'config/initializers/thredded.rb',
                /# Thredded\.email_from = .*/,
                <<~'RUBY'.chomp
                  Thredded.email_from = %("#{I18n.t('brand.name')}" <#{Settings.email_sender}>)
                RUBY

        add_precompile_asset 'email.css'

        File.write 'config/initializers/roadie.rb', <<~'RUBY', mode: 'a'
          Rails.application.config.roadie.before_transformation = Thredded::EmailTransformer
        RUBY
      end

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def configure_rails_email_preview
        replace 'config/routes.rb',
                /\s*mount RailsEmailPreview::Engine.*/,
                indent(2, "\n" + <<~'RUBY' + "\n")
                  scope path: 'admin' do
                    authenticate :user, lambda { |u| u.admin? } do
                      mount RailsEmailPreview::Engine, at: 'emails'
                    end
                  end
        RUBY
        replace 'config/initializers/rails_email_preview.rb',
                /#\s?(RailsEmailPreview\.setup.*?\n)(.*?)#\s?end/m do |m|
                  content = m[2]
                  content.gsub!(/^#( {2}#|$)/, '\1') || fail
                  content.gsub!(/^#/, '  #')
                  content.gsub!(/ *# *config.before_render.*?end\n/m,
                                indent(2, <<~'RUBY')) || fail
                                  config.before_render do |message, preview_class_name, mailer_action|
                                    Roadie::Rails::MailInliner.new(message, message.roadie_options).execute
                                  end
                                RUBY
                  content.gsub!(/ *# *config.enable_send_email =.*\n/,
                                indent(2, <<~'RUBY')) || fail
                                  config.enable_send_email = Rails.env.production?
                                RUBY
                  content.gsub!(/# do not show send email button/i,
                                '# Only show Send Email button in production')
                  "#{m[1]}#{content}end"
                end
        replace 'config/initializers/rails_email_preview.rb',
                /#\s*RailsEmailPreview.layout =.*/,
                "RailsEmailPreview.layout = 'application'"
        replace 'config/initializers/rails_email_preview.rb',
                /RailsEmailPreview.preview_classes = /,
                'RailsEmailPreview.preview_classes = ' \
                        'Thredded::BaseMailerPreview.preview_classes + '
      end
      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize
    end
  end
end
