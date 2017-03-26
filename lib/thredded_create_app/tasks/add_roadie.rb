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
        inject_into_file 'config/environments/test.rb',
                         before: /\nend\n\z$/,
                         content: indent(2, "\n" + roadie_development_config)
        inject_into_file 'config/environments/development.rb',
                         before: /\nend\n\z$/,
                         content: indent(2, "\n" + roadie_development_config)
        inject_into_file 'config/environments/production.rb',
                         before: /\nend\n\z$/,
                         content: indent(2, "\n" + roadie_production_config)
        replace 'app/views/layouts/mailer.html.erb',
                %r{ *<style>.*?</style>\n}m,
                indent(4, mailer_template_head)
        git_commit 'Add Roadie configuration'
      end

      private

      def mailer_template_head
        <<~'ERB'
          <%# Ensure the stylesheet is referenced without a host so that the local
              version is read by Roadie even if asset_host is set. %>
          <link rel="stylesheet" href="<%= stylesheet_path('email', host: '') %>" />
        ERB
      end

      def roadie_development_config
        <<~'RUBY'
          # Set the default URL options for both Roadie and ActionMailer:
          config.roadie.url_options = config.action_mailer.default_url_options = {
            host: 'localhost',
            port: 3000,
          }
        RUBY
      end

      def roadie_production_config
        <<~'RUBY'
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
