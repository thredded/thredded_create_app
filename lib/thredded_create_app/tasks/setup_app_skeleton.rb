# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class SetupAppSkeleton < Base # rubocop:disable Metrics/ClassLength
      MATERIAL_700_COLORS = [
        '#7B1FA2', # purple
        '#512DA8', # deep purple
        '#303F9F', # indigo
        '#1976D2', # blue
        '#0288D1', # light blue
        '#0097A7', # cyan
        '#00796B', # teal
        '#F57C00', # orange
      ].freeze

      def summary
        'Setup basic app navigation and styles'
      end

      def before_bundle
        add_gem 'rails-timeago'
      end

      def after_bundle
        add_favicon_and_touch_icons
        add_javascripts
        add_styles
        add_user_page
        add_home_page
        add_i18n
        add_app_layout
        copy 'setup_app_skeleton/spec/features/homepage_spec.rb',
             'spec/features/homepage_spec.rb'
        add_seeds
        git_commit 'Set up basic app navigation and styles'
      end

      def add_favicon_and_touch_icons
        FileUtils.mv 'public/favicon.ico',
                     'app/assets/images/favicon.ico'
        FileUtils.mv 'public/apple-touch-icon.png',
                     'app/assets/images/apple-touch-icon.png'
        # The `-precomposed.png` touch icon is only used by iOS < 7, remove it.
        # Do not raise if the file does not exist, as Rails will stop generating
        # it one of these days.
        FileUtils.rm 'public/apple-touch-icon-precomposed.png', force: true

        inject_into_file 'app/views/layouts/application.html.erb',
                         before: '    <%= csrf_meta_tags %>',
                         content: indent(4, <<~ERB)
          <%= favicon_link_tag 'favicon.ico' %>
          <%= favicon_link_tag 'apple-touch-icon.png',
                               rel: 'apple-touch-icon', type: 'image/png' %>
        ERB
      end

      def add_javascripts
        replace 'app/assets/javascripts/application.js',
                %r{^//= require jquery$},
                '//= require jquery3'
        git_commit 'Use jQuery v3 instead of jQuery v1'
      end

      def add_styles
        copy_template 'setup_app_skeleton/_variables.scss.erb',
                      'app/assets/stylesheets/_variables.scss'

        if File.file? 'app/assets/stylesheets/application.css'
          File.delete 'app/assets/stylesheets/application.css'
        end
        copy_template 'setup_app_skeleton/application.scss',
                      'app/assets/stylesheets/application.scss',
                      mode: 'a'
        copy 'setup_app_skeleton/_flash-messages.scss',
             'app/assets/stylesheets/_flash-messages.scss'
      end

      def add_i18n
        copy_template 'setup_app_skeleton/en.yml.erb',
                      'config/locales/en.yml'
      end

      def add_app_layout # rubocop:disable Metrics/MethodLength
        copy 'setup_app_skeleton/_header.html.erb',
             'app/views/shared/_header.html.erb'
        copy 'setup_app_skeleton/_flash_messages.html.erb',
             'app/views/shared/_flash_messages.html.erb'
        app_helper_src = File.read(
          File.join(File.dirname(__FILE__),
                    'setup_app_skeleton/application_helper_methods.rb')
        )
        inject_into_file 'app/helpers/application_helper.rb',
                         before:  /end\n\z/,
                         content: indent(2, app_helper_src)
        replace 'app/views/layouts/application.html.erb',
                %r{<title>.*?</title>},
                '<title><%= page_title %></title>'
        replace 'app/views/layouts/application.html.erb',
                /[ ]*<%= javascript_include_tag 'application', .*? %>/,
                <<-'ERB'
    <%= javascript_include_tag 'application',
                                async: !Rails.application.config.assets.debug,
                                defer: true,
                                'data-turbolinks-track': 'reload' %>
        ERB

        inject_into_file 'app/views/layouts/application.html.erb',
                         before: '</head>',
                         content: <<-'ERB'
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        ERB

        replace 'app/views/layouts/application.html.erb',
                %r{<body>.*?</body>}m,
                File.read(
                  File.join(File.dirname(__FILE__),
                            'setup_app_skeleton/application.body.html.erb')
                )
      end

      def add_user_page
        run_generator 'controller users show' \
                      ' --no-assets --no-helper --skip-routes'
        copy 'setup_app_skeleton/spec/controllers/users_controller_spec.rb',
             'spec/controllers/users_controller_spec.rb'
        copy 'setup_app_skeleton/users_show.html.erb',
             'app/views/users/show.html.erb'
        replace 'app/controllers/users_controller.rb', 'def show', <<-'RUBY'
  def show
    @user = User.find(params[:id])
        RUBY
        # The route must be defined after `devise_for`.
        # The route is injected before Thredded in case Thredded is mount at /.
        inject_into_file 'config/routes.rb',
                         before: /^\s*mount Thredded::Engine/,
                         content: indent(2, <<~'RUBY')
          resources :users, only: [:show]
        RUBY
      end

      def add_home_page
        run_generator 'controller home show' \
                      ' --no-assets --no-helper --skip-routes'
        add_route <<~'RUBY', prepend: true
          root to: 'home#show'
        RUBY
        copy_template 'setup_app_skeleton/home_show.html.erb.erb',
                      'app/views/home/show.html.erb'
      end

      def add_seeds
        copy_template 'setup_app_skeleton/seeds.rb.erb',
                      'db/seeds.rb'
      end

      def admin_email
        "admin@#{app_name.tr(' ', '_').downcase}.com"
      end

      def admin_password
        '123456'
      end

      def brand_primary
        @brand_primary ||= MATERIAL_700_COLORS.sample.downcase
      end
    end
  end
end
