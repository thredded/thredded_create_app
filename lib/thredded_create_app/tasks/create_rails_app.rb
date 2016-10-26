# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class CreateRailsApp < Base
      def summary
        "Create Rails app #{app_name.inspect} with postgresql and rspec"
      end

      def before_bundle
        system_with_log 'gem update --system --no-document --quiet'
        system_with_log 'gem install bundler rails --no-document'
        system_with_log 'rails new . --skip-bundle --database=postgresql ' \
           '--skip-test --quiet'
        add_gem 'rspec-rails', groups: %i(test)
      end

      def after_bundle
        system_with_log 'bundle exec rails g rspec:install --quiet'
      end
    end
  end
end
