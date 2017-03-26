# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddRailsEmailPreview < Base
      def summary
        'Add and configure RailsEmailPreview'
      end

      def before_bundle
        add_gem 'rails_email_preview'
      end

      def after_bundle
        run_generator 'rails_email_preview:install'
        add_styles
        git_commit 'rails g rails_email_preview:install'
      end

      private

      def add_styles
        if File.file? 'app/assets/stylesheets/application.css'
          File.delete 'app/assets/stylesheets/application.css'
        end
        copy 'add_rails_email_preview/_rails_email_preview-custom.scss',
             'app/assets/stylesheets/_rails_email_preview-custom.scss'

        File.write 'app/assets/stylesheets/application.scss', <<~SCSS, mode: 'a'
          @import "rails_email_preview-custom";
        SCSS
      end
    end
  end
end
