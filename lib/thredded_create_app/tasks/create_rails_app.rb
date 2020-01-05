# frozen_string_literal: true

require 'bundler'
require 'yaml'
require_relative './base'

module ThreddedCreateApp
  module Tasks
    class CreateRailsApp < Base
      def initialize(install_gem_bundler_rails:, rails_version:, database:,
                     **args)
        super
        @install_gem_bundler_rails = install_gem_bundler_rails
        @database = database
        @rails_version = rails_version
        @user_install = !File.writable?(Gem.dir)
      end

      def summary
        "Create a Rails v#{@rails_version} app #{app_name.inspect} with"\
          " #{rails_database} and rspec"
      end

      def before_bundle # rubocop:disable Metrics/AbcSize
        if @install_gem_bundler_rails
          run 'gem update --system --no-document --quiet' unless @user_install
          install_gem 'bundler'
          install_gem 'rails', version: @rails_version
        end
        @rails_version ||=
          Bundler.with_original_env { latest_installed_rails_version }

        run "rails _#{@rails_version}_ new . --skip-bundle" \
           " --database=#{rails_database}" \
           ' --skip-webpack-install' \
           "#{' --skip-javascript' unless webpack_js?}" \
           ' --skip-test' \
           "#{verbose? ? ' --verbose' : ' --quiet'}"
        run 'rm', 'Gemfile.lock' if File.exist?('Gemfile.lock')
        replace 'Gemfile', /gem 'sass-rails'.*$/, "gem 'sassc-rails'"
        add_gem 'rspec-rails', version: '>= 4.0.0.beta3', groups: %i[test]
        add_gem 'capybara', groups: %i[test]
        git_commit summary
      end

      def after_bundle
        run_generator 'rspec:install'
        git_commit 'rails g rspec:install'

        webpacker_install if webpack_js?
      end

      private

      def webpacker_install
        run 'bundle exec rails webpacker:install'
        git_commit 'bundle exec rails webpacker:install'
      end

      def install_gem(gem_name, version: nil)
        run ["gem install #{gem_name} --no-document",
             ('--user' if @user_install),
             ("-v #{version}" if version)].compact.join(' ')
      end

      def rails_database
        { mysql2: :mysql }.fetch(@database, @database)
      end

      def latest_installed_rails_version
        # rubocop:disable Security/YAMLLoad
        YAML.load(`gem specification rails`).version.to_s
        # rubocop:enable Security/YAMLLoad
      end
    end
  end
end
