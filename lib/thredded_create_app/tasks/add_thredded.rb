# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddThredded < Base
      def summary
        'Add and setup Thredded with a User model'
      end

      def before_bundle
        add_gem 'thredded'
        add_gem 'sassc'
      end

      def after_bundle
        install_thredded
        git_commit 'Install thredded (rails g thredded:install)'
        add_thredded_routes
        add_thredded_styles
        add_thredded_javascripts
        git_commit 'Add Thredded routes, styles, and javascripts'
        add_admin_column_to_users
        git_commit 'Add the admin column to users'
      end

      private

      def install_thredded
        run_generator 'thredded:install'
      end

      def add_thredded_routes
        add_route "mount Thredded::Engine => '/forum'"
      end

      def add_thredded_styles
        copy 'add_thredded/_myapp_thredded.scss',
             "app/assets/stylesheets/_#{app_name}_thredded.scss"
        if File.file? 'app/assets/stylesheets/application.css'
          File.delete 'app/assets/stylesheets/application.css'
        end
        File.write 'app/assets/stylesheets/application.scss',
                   "@import \"#{app_name}_thredded\";",
                   mode: 'a'
      end

      def add_thredded_javascripts
        copy 'add_thredded/myapp_thredded.js',
             "app/assets/javascripts/#{app_name}_thredded.js"
      end

      def add_admin_column_to_users
        run_generator 'migration add_admin_to_users'
        copy 'add_thredded/add_admin_to_users.rb',
             Dir['db/migrate/*_add_admin_to_users.rb'][0]
      end
    end
  end
end
