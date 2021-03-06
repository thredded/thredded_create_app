# frozen_string_literal: true

require 'bundler'
require 'fileutils'
require 'shellwords'
require_relative './tasks/base'
require_relative './tasks/create_rails_app'
require_relative './tasks/add_rails_config'
require_relative './tasks/add_simple_form'
require_relative './tasks/add_devise'
require_relative './tasks/add_roadie'
require_relative './tasks/add_rails_email_preview'
require_relative './tasks/add_thredded'
require_relative './tasks/add_display_name_to_users'
require_relative './tasks/add_invisible_captcha'
require_relative './tasks/setup_database'
require_relative './tasks/setup_app_skeleton'
require_relative './tasks/production_configs'
require_relative './tasks/add_memcached_support'
require_relative './tasks/docker'

module ThreddedCreateApp
  class Generator < Tasks::Base
    def initialize(**options)
      super
      @options = options
    end

    def summary
      tasks.map { |t| "* #{t.summary}" }.join("\n")
    end

    def generate
      log_verbose "Started: #{inspect}"
      FileUtils.mkdir_p(app_path)
      in_app_env do
        run 'git init .'
        @tasks.each(&:before_bundle)
        bundle
        @tasks.each(&:after_bundle)
      end
    end

    def run_tests!
      log_info 'Running tests'
      in_app_env do
        run 'bundle exec rspec -fd'
      end
    end

    private

    def in_app_env
      bundle_gemfile_was = ENV['BUNDLE_GEMFILE']
      Dir.chdir app_path do
        Bundler.with_original_env do
          ENV['BUNDLE_GEMFILE'] = 'Gemfile'
          yield
        end
      end
    ensure
      ENV['BUNDLE_GEMFILE'] = bundle_gemfile_was
    end

    def tasks
      @tasks ||= [
        Tasks::CreateRailsApp,
        Tasks::AddRailsConfig,
        (Tasks::AddSimpleForm if @options[:simple_form]),
        Tasks::AddDevise,
        Tasks::AddRailsEmailPreview,
        Tasks::AddRoadie,
        Tasks::AddThredded,
        Tasks::AddDisplayNameToUsers,
        Tasks::AddInvisibleCaptcha,
        Tasks::SetupAppSkeleton,
        Tasks::ProductionConfigs,
        Tasks::AddMemcachedSupport,
        (Tasks::Docker if @options[:database] == :postgresql),
        Tasks::SetupDatabase
      ].compact.map { |task_class| task_class.new(@options) }
    end

    def gems
      tasks.flat_map(&:gems)
    end

    # @final
    def bundle
      gemfile_contents = File.read('Gemfile')
      gems_to_add = gems.reject do |gem|
        gemfile_contents =~ /^gem\s*['"]#{Regexp.escape(gem[0])}['"]/
      end
      log_info 'Writing gems to Gemfile'
      add_gems_to_gemfile gems_to_add
      log_info 'Installing gems'
      install_gems
      git_commit "Add gems: #{gems_to_add.map { |(name, *)| name } * ', '}"
    end

    def add_gems_to_gemfile(gems)
      File.open('Gemfile', 'a') do |f|
        gems.each do |(name, version, require, groups, path)|
          f.puts ["gem '#{name}'",
                  ("'#{version}'" if version),
                  ("require: '#{require}'" if require),
                  ("groups: %i[#{groups * ' '}]" if groups),
                  ("path: '#{path}'" if path)].compact.join(', ')
        end
      end
    end

    def install_gems
      cache_path = ENV['THREDDED_CREATE_APP_BUNDLE_CACHE']
      if cache_path
        FileUtils.mkdir_p cache_path
        run 'ln', '-s', cache_path, 'vendor/cache'
      end
      run 'bundle', 'install', '--with=test',
          *('--quiet' unless verbose?),
          *(%w[--path .bundle] unless File.writable?(Gem.dir))
      run 'bundle', 'package', *('--quiet' unless verbose?) if cache_path
    end
  end
end
