# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class CreateRailsApp < Base
      def initialize(install_gem_bundler_rails: false, **args)
        super
        @install_gem_bundler_rails = install_gem_bundler_rails
      end

      def summary
        "Create Rails app #{app_name.inspect} with postgresql and rspec"
      end

      def before_bundle
        if @install_gem_bundler_rails
          run 'gem update --system --no-document --quiet'
          run 'gem install bundler rails --no-document'
        end
        # I have no idea why this bundle exec is necessary on Travis.
        run "#{'bundle exec ' if ENV['TRAVIS']}" \
           'rails new . --skip-bundle --database=postgresql ' \
           "--skip-test#{verbose? ? ' --verbose' : ' --quiet'}"
        replace 'Gemfile', /gem 'sass-rails'.*$/, "gem 'sassc-rails'"
        add_gem 'rspec-rails', groups: %i(test)
        add_gem 'capybara', groups: %i(test)
        git_commit summary
      end

      def after_bundle
        run_generator 'rspec:install'
        git_commit 'rails g rspec:install'
      end
    end
  end
end
