# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddQueueClassic < Base
      def summary
        'Add QueueClassic for background jobs'
      end

      def before_bundle
        add_gem 'que'
        add_gem 'queue_classic_admin',
                "git: 'https://github.com/PSPDFKit-labs/queue_classic_admin'"
      end

      def after_bundle
        run_generator 'queue_classic:install'
        git_commit 'Install QueueClassic (rails g que:install)'
        add_route <<~'RUBY'
          authenticate :user, lambda { |u| u.admin? } do
            mount QueueClassicAdmin::Engine, at: 'admin/background-jobs', as: :admin_background_jobs
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
