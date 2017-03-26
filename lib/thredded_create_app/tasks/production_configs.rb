# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class ProductionConfigs < Base
      def summary
        'Add production configuration files'
      end

      def before_bundle
        copy 'production_configs/puma.production.rb',
             'config/puma.production.rb'
        git_commit 'Add production puma config file'

        copy 'production_configs/Procfile',
             'Procfile'
        git_commit 'Add Procfile'
      end
    end
  end
end
