# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddRoadie < Base
      def summary
        'Add and configure the Roadie email pre-processor'
      end

      def before_bundle
        add_gem 'roadie-rails'
        add_gem 'plain-david' # for plain text email generation
      end

      def after_bundle
        inject_into_file 'app/mailers/application_mailer.rb',
                         after: "ActionMailer::Base\n",
                         content: "  include Roadie::Rails::Automatic\n"
        inject_into_file 'config/environments/production.rb',
                         before: /\nend\n\z$/,
                         content: indent(2, "\n" + roadie_production_config)
        replace 'app/views/layouts/mailer.html.erb',
                %r{<style>.*?</style>}m,
                "<%= stylesheet_link_tag 'email' %>"
        git_commit 'Add Roadie configuration'
      end

      private

      def roadie_production_config
        <<~'RUBY'
          # Roadie requires that action_mailer.asset_host is nil, see:
          # https://github.com/Mange/roadie-rails/blob/9e3cb2ed59f4ec9fda252ad016b23e106983a440/README.md#known-issues
          config.action_mailer.asset_host = nil
          # Set the default URL options for both Roadie and ActionMailer:
          config.roadie.url_options = config.action_mailer.default_url_options = {
            host: ENV['APP_HOST'] || '[SET ME] myapp.herokuapp.com',
            protocol: 'https',
          }
        RUBY
      end
    end
  end
end
