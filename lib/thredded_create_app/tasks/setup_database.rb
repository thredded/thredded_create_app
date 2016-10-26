# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
require 'securerandom'
module ThreddedCreateApp
  module Tasks
    class SetupDatabase < Base
      def summary
        'Create the database user, configure database.yml, and run migrations'
      end

      def after_bundle
        log_info 'Creating config/database.yml from template'
        copy_template 'setup_database/database.yml.erb', 'config/database.yml'
        create_db_user
        run 'bundle exec rails db:create db:migrate'
      end

      private

      def create_db_user
        log_info "Creating #{dev_user} local database user"
        run 'bash',
            File.join(File.dirname(__FILE__), 'setup_database',
                      'create_postgresql_user.sh'),
            dev_user,
            dev_user_password,
            log: false
      end

      def dev_user
        "#{app_name}_dev"
      end

      def dev_user_password
        @dev_user_password ||= SecureRandom.urlsafe_base64(20)
      end
    end
  end
end
