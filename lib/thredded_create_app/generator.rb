# frozen_string_literal: true
require 'fileutils'
require 'shellwords'
require 'thredded_create_app/tasks/base'
require 'thredded_create_app/tasks/create_rails_app'
require 'thredded_create_app/tasks/add_simple_form'
require 'thredded_create_app/tasks/add_devise'
require 'thredded_create_app/tasks/add_thredded'
require 'thredded_create_app/tasks/add_display_name_to_users'
require 'thredded_create_app/tasks/setup_database'
require 'thredded_create_app/tasks/setup_app_skeleton'
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
      Bundler.with_clean_env do
        Dir.chdir(app_path) do
          run 'git init .'
          @tasks.each(&:before_bundle)
          bundle
          @tasks.each(&:after_bundle)
        end
      end
    end

    private

    def tasks
      @tasks ||= [
        Tasks::CreateRailsApp,
        (Tasks::AddSimpleForm if @options[:simple_form]),
        Tasks::AddDevise,
        Tasks::AddThredded,
        Tasks::AddDisplayNameToUsers,
        Tasks::SetupAppSkeleton,
        Tasks::SetupDatabase
      ].compact.map { |task_class| task_class.new(@options) }
    end

    def gems
      tasks.flat_map(&:gems)
    end

    # @final
    def bundle
      File.open('Gemfile', 'a') do |f|
        log_info 'Writing gems to Gemfile'
        gems.each do |(name, version, groups)|
          f.puts ["gem '#{name}'",
                  (version if version),
                  ("groups: %i(#{groups * ' '})" if groups)].compact.join(', ')
        end
      end
      run "bundle install#{' --quiet' unless verbose?}"
      git_commit "Add gems: #{gems.map { |(name, *)| name } * ', '}"
    end
  end
end
