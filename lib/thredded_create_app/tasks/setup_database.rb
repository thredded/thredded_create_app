# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class SetupDatabase < Base
      # @param [:postgresql, :mysql2, :sqlite3] database the DB db_adapter name.
      def initialize(database:, **_args)
        super
        @db_adapter = database
      end

      def summary
        'Create the database user, configure database.yml, and run migrations'
      end

      def after_bundle
        log_info 'Creating config/database.yml from template'
        copy_template 'setup_database/database.yml.erb', 'config/database.yml'
        create_db_user
        run 'bundle exec rails db:create db:migrate db:seed' \
            "#{' --quiet' unless verbose?}"
        git_commit 'Configure the database'
      end

      private

      def create_db_user
        return if @db_adapter == :sqlite3
        log_info "Creating #{dev_user} local database user"
        run 'bash',
            File.join(File.dirname(__FILE__), 'setup_database',
                      'create_database_user.sh'),
            @db_adapter.to_s,
            app_name,
            dev_user,
            dev_user_password,
            ENV['TRAVIS'] || '',
            log: false
      end

      # @return [Symbol]
      attr_reader :db_adapter

      def dev_user
        "#{app_name}_dev"
      end

      def dev_user_password
        # Use a fixed password so that multiple runs of thredded_create_app
        # don't fail.
        @dev_user_password ||= app_name
      end
    end
  end
end
