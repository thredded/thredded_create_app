# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class Docker < Base
      def summary
        'Add Docker configuration files for development'
      end

      def before_bundle
        copy_template 'docker/Dockerfile.erb',
                      'Dockerfile'
        copy_template 'docker/docker-compose.yml.erb',
                      'docker-compose.yml'
        copy 'docker/wait-for-tcp',
             'script/wait-for-tcp'
        run 'chmod +x script/wait-for-tcp'
        git_commit 'Add Docker compose for development'
      end
    end
  end
end
