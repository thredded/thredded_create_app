# frozen_string_literal: true
require 'thredded_create_app/logging'
require 'shellwords'
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

      attr_reader :app_name, :app_path, :gems

      def system_with_log(*args)
        log_command args.length == 1 ? args[0] : Shellwords.shelljoin(args)
        unless system(*args)
          exit 1
        end
      end
    end
  end
end
