# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddThredded < Base
      def before_bundle
        add_gem 'thredded'
        add_gem 'sassc'
      end

      def after_bundle
        add_user_columns
        git_commit 'Add display_name and admin columns to User'
        install_thredded
        setup_thredded_assets
        git_commit 'Setup Thredded'
      end

      private

      def add_user_columns
        run_generator 'migration add_display_name_and_admin_to_users'
        copy 'add_thredded/add_display_name_and_admin_to_users.rb',
             Dir['db/migrate/*_add_display_name_and_admin_to_users.rb'][0]
      end

      def install_thredded
        run_generator 'thredded:install'
        replace 'config/initializers/thredded.rb',
                'Thredded.user_name_column = :name',
                'Thredded.user_name_column = :display_name'
        add_route "mount Thredded::Engine => '/forum'"
      end

      def setup_thredded_assets
        copy 'add_thredded/_myapp_thredded.scss',
             "app/assets/stylesheets/_#{app_name}_thredded.scss"
        copy 'add_thredded/myapp_thredded.js',
             "app/assets/javascripts/#{app_name}_thredded.js"
        if File.file? 'app/assets/stylesheets/application.css'
          File.delete 'app/assets/stylesheets/application.css'
        end
        File.write 'app/assets/stylesheets/application.scss',
                   "@import \"#{app_name}_thredded\";",
                   mode: 'a'
      end
    end
  end
end
