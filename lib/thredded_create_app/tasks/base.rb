# frozen_string_literal: true
require 'shellwords'
require 'fileutils'
require 'erb'
require 'thredded_create_app/logging'
module ThreddedCreateApp
  module Tasks
    # @abstract
    class Base
      include ThreddedCreateApp::Logging

      def initialize(app_path:, **_args)
        @app_path = app_path
        @app_name = File.basename(File.expand_path(app_path))
        @gems = []
      end

      def summary
        self.class.name
      end

      def before_bundle
      end

      def after_bundle
      end

      protected

      def add_gem(gem_name, version: nil, groups: nil)
        log_info "+ gem #{gem_name}"
        @gems << [gem_name, version, groups]
      end

      def git_commit(message)
        log_info 'Commiting'
        system 'git add .'
        system 'git', 'commit', '-m', "[thredded_create_app] #{message}"
      end

      attr_reader :app_name, :app_path, :gems

      def copy_template(src_path, target_path, eval_erb: true)
        src = File.read(File.expand_path(src_path, File.dirname(__FILE__)))
        src = ERB.new(src).result(binding) if eval_erb
        FileUtils.mkdir_p(File.dirname(target_path))
        File.open(target_path, 'wb') { |f| f.write src }
      end

      def run(*args, log: true)
        if log
          log_command args.length == 1 ? args[0] : Shellwords.shelljoin(args)
        end
        exit 1 unless system(*args)
      end
    end
  end
end
