# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddInvisibleCaptcha < Base
      def initialize(simple_form: true, **_args)
        super
        @simple_form = simple_form
      end

      def summary
        'Add an invisible captcha to the sign up form'
      end

      def before_bundle
        add_gem 'invisible_captcha'
      end

      def after_bundle
        inject_into_file 'app/controllers/users/registrations_controller.rb',
                         after: "::Devise::RegistrationsController\n",
                         content: <<-RUBY
    invisible_captcha only: %i[create], honeypot: :name
        RUBY

        form_view_path = 'app/views/devise/registrations/new.html.erb'
        form_view_captcha = '<%= invisible_captcha :name %>'
        if @simple_form
          inject_into_file form_view_path,
                           after: %(<div class="form-inputs">\n),
                           content: "    #{form_view_captcha}\n"
        else
          inject_into_file form_view_path,
                           after: %r{render "devise/shared/error_messages", resource: resource %>\n\n},
                           content: "  #{form_view_captcha}\n\n"
        end
        inject_into_file form_view_path,
                         before: ') do |f|',
                         content: ", html: {autocomplete: 'off'}"

        git_commit 'Add invisible_captcha to the sign up form'
      end
    end
  end
end
