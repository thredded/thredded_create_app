# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddQue < Base
      def summary
        'Add Que for background jobs'
      end

      def before_bundle
        add_gem 'que'
      end

      def after_bundle
        run_generator 'que:install'
        git_commit 'Install Que (rails g que:install)'
        add_route <<~'RUBY'
          authenticate :user, lambda { |u| u.admin? } do
            mount Que::Web, at: 'admin/que', as: :que
          end
        RUBY
        inject_into_file 'config/application.rb',
                         after: "Rails::Application\n",
                         content: 'config.active_record.schema_format = :sql'
        replace 'config/environments/production.rb',
                /^.*config\.active_job\.queue_adapter.*$/,
                indent(2, <<~RUBY)
                  config.active_job.queue_adapter = :que
                  # Que only supports one queue per worker
                  config.action_mailer.deliver_later_queue_name = 'default'
                RUBY

        git_commit 'Configure the app for que'
      end
    end
  end
end
