# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddJquery < Base
      def summary
        'Add jQuery v3'
      end

      def before_bundle
        add_gem 'jquery-rails'
      end

      def after_bundle
        if replace 'app/assets/javascripts/application.js',
                   %r{^//= require jquery$},
                   '//= require jquery3',
                   optional: true
          git_commit 'Use jQuery v3 instead of jQuery v1'
        else
          inject_into_file 'app/assets/javascripts/application.js',
                           content: "//= require jquery3\n",
                           before: '//='
          git_commit 'Add jQuery'
        end
      end
    end
  end
end
