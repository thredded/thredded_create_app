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
        model_path = 'app/models/user.rb'
        inject_into_file model_path,
                         after:   "ApplicationRecord\n",
                         content: display_name_model_rb
        inject_into_file model_path,
                         before:  /end\n\z/,
                         content: uniq_display_name_method_rb
        git_commit 'Add a unique display_name User attribute'
      end

      def configure_devise
        inject_into_file 'app/controllers/application_controller.rb',
                         after:   /protect_from_forgery.*\n/,
                         content: devise_permitted_params_rb
        %w(app/views/devise/registrations/new.html.erb
           app/views/devise/registrations/edit.html.erb).each do |path|
          autofocus = File.read(path).include?(', autofocus: true')
          replace path, ', autofocus: true', '' if autofocus
          if @simple_form
            inject_into_file path,
                             after:   %(<div class="form-inputs">\n),
                             content: simple_form_input_html(autofocus)
          else
            inject_into_file path,
                             after:   /error_messages! %>\n\n/,
                             content: actionview_input_html(autofocus)
          end
        end
        git_commit 'Configure Devise to support display_name in forms'
      end

      def configure_thredded
        replace 'config/initializers/thredded.rb',
                'Thredded.user_name_column = :name',
                'Thredded.user_name_column = :display_name'
        git_commit 'Configure Thredded to use display_name as the user name'
      end

      def display_name_model_rb
        <<-'RUBY'
  validates :display_name, presence: true, uniqueness: true
  before_validation :uniq_display_name!, on: :create

  def display_name=(value)
    super(value ? value.strip : nil)
  end

        RUBY
      end

      def uniq_display_name_method_rb
        <<-'RUBY'
  private

  # Makes the display_name unique by appending a number to it if necessary.
  # "Gleb" => Gleb 1"
  def uniq_display_name!
    if display_name.present?
      new_display_name = display_name
      i  = 0
      while User.exists?(display_name: new_display_name)
        new_display_name = "#{display_name} #{i += 1}"
      end
      self.display_name = new_display_name
    end
  end
        RUBY
      end

      def devise_permitted_params_rb
        <<-'RUBY'
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(display_name))
    devise_parameter_sanitizer.permit(:account_update, keys: %i(display_name))
  end
        RUBY
      end

      def simple_form_input_html(autofocus)
        <<-HTML
  <%= f.input :display_name, required: true#{', autofocus: true' if autofocus} %>
        HTML
      end

      def actionview_input_html(autofocus)
        <<-HTML
  <div class="field">
    <%= f.label :display_name %><br />
    <%= f.text_field :display_name#{', autofocus: true' if autofocus} %>
  </div>

        HTML
      end
    end
  end
end
