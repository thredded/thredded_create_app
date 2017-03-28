# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddRailsConfig < Base
      def summary
        'Add the config gem'
      end

      def before_bundle
        add_gem 'config'
      end

      def after_bundle
        run_generator 'config:install'
        git_commit 'Add Rails Config configuration (rails g config:install)'
        inject_into_file 'config/initializers/config.rb',
                         before: /\A/,
                         content: config_initializer_header
      end

      private

      def config_initializer_header
        <<~'RUBY'
          # frozen_string_literal: true

          # This file *must* be named "config.rb". It is loaded manually by the config
          # gem before everything else, so you can use the Settings constant even in
          # config/application.rb and config/environments/*.
        RUBY
      end
    end
  end
end
