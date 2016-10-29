# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddDisplayNameToUsers < Base
      def initialize(simple_form: true, **args)
        super
        @simple_form = simple_form
      end

      def summary
        'Add display_name to the Devise User model'
      end

      def after_bundle
        add_display_name
        configure_devise
        configure_thredded
      end

      private

      def add_display_name
        run_generator 'migration add_display_name_to_users'
        copy 'add_display_name_to_users/add_display_name_to_users.rb',
             Dir['db/migrate/*_add_display_name_to_users.rb'][0]
        inject_into_file 'app/models/user.rb', after: "ApplicationRecord\n",
                                               content: <<-RUBY
  validates :display_name, presence: true, uniqueness: true

  def display_name=(value)
    super(value&.strip)
  end
        RUBY
        git_commit 'Add a unique display_name User attribute'
      end

      def configure_devise
        run_generator 'devise:i18n:views -v registrations'
        %w(app/views/devise/registrations/new.html.erb
           app/views/devise/registrations/edit.html.erb).each do |path|
          autofocus = File.read(path).include?(', autofocus: true')
          replace path, ', autofocus: true', '' if autofocus
          if @simple_form
            inject_into_file path, after: %(<div class="form-inputs">\n),
                                   content: <<-HTML
  <%= f.input :display_name, required: true#{', autofocus: true' if autofocus} %>
            HTML
          else
            inject_into_file path, after: /error_messages! %>\n\n/,
                                   content: <<-HTML
  <div class="field">
    <%= f.label :display_name %><br />
    <%= f.text_field :display_name#{', autofocus: true' if autofocus} %>
  </div>

            HTML
          end
        end
        # TODO: add to permitted attrs.
        git_commit 'Configure Devise to support display_name in forms'
      end

      def configure_thredded
        replace 'config/initializers/thredded.rb',
                'Thredded.user_name_column = :name',
                'Thredded.user_name_column = :display_name'
        git_commit 'Configure Thredded to use display_name as the user name'
      end
    end
  end
end
