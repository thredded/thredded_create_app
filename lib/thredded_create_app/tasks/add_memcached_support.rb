# frozen_string_literal: true

require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class AddMemcachedSupport < Base
      def summary
        'Add memcached support via the dalli memcached client'
      end

      def before_bundle
        add_gem 'dalli'
        add_gem 'connection_pool'
      end

      def after_bundle
        inject_into_file 'config/environments/production.rb',
                         before:  /end\n\z/,
                         content: dalli_config
      end

      private

      def dalli_config
        <<-RUBY

  # Configure memcached as the cache store
  if ENV['MEMCACHE_SERVERS']
    config.cache_store = :dalli_store,
        ENV['MEMCACHE_SERVERS'].split(','), {
            namespace: '#{app_name}',
            socket_timeout: 1.5,
            socket_failure_delay: 0.2,
            down_retry_delay: 60,
            pool_size: [2, ENV.fetch('WEB_CONCURRENCY', 3).to_i *
                           ENV.fetch('MAX_THREADS', 5).to_i].max
        }
  elsif ENV['MEMCACHEDCLOUD_SERVERS']
    config.cache_store = :dalli_store,
        ENV['MEMCACHEDCLOUD_SERVERS'].split(','), {
            username: ENV['MEMCACHEDCLOUD_USERNAME'],
            password: ENV['MEMCACHEDCLOUD_PASSWORD'],
            pool_size: [2, ENV.fetch('WEB_CONCURRENCY', 3).to_i *
                           ENV.fetch('MAX_THREADS', 5).to_i].max
        }
  end
        RUBY
      end
    end
  end
end
