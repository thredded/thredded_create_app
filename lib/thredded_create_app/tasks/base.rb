# frozen_string_literal: true

require 'shellwords'
require 'fileutils'
require 'erb'
require 'thredded_create_app/logging'
require 'thredded_create_app/command_error'
module ThreddedCreateApp
  module Tasks
    # @abstract
    class Base
      include ThreddedCreateApp::Logging

      attr_reader :app_name, :app_hostname, :app_path, :gems

      def initialize(
          app_path:, verbose: false, database:, simple_form: true, **_args
      )
        @app_path = app_path
        @app_name = File.basename(File.expand_path(app_path))
        @app_hostname = "#{@app_name.tr(' ', '_').downcase}.com"
        @verbose = verbose
        @database_adapter_name = database.to_s
        @gems = []
        @simple_form = simple_form
      end

      def devise_form_fields_begin_pattern
        if @simple_form
          %(<div class="form-inputs">\n)
        else
          %r{render "devise/shared/error_messages", resource: resource %>\n\n}
        end
      end

      def summary
        self.class.name
      end

      def before_bundle; end

      def after_bundle; end

      protected

      attr_reader :database_adapter_name

      def add_gem(gem_name, version: nil, require: nil, groups: nil, path: nil)
        log_verbose "+ gem #{gem_name}"
        @gems << [gem_name, version, require, groups, path]
      end

      def git_commit(message)
        log_info "Commiting: #{message}"
        system 'git add -A .'
        system(*['git', 'commit', '-m', "[thredded_create_app] #{message}",
                 ('--quiet' unless verbose?)].compact)
      end

      def expand_src_path(src_path)
        File.expand_path src_path, File.dirname(__FILE__)
      end

      def copy(src_path, target_path, mode: 'w')
        copy_template src_path, target_path, process_erb: false, mode: mode
      end

      def copy_template(src_path, target_path, process_erb: true, mode: 'w')
        expanded_src_path = expand_src_path(src_path)
        if File.directory?(expanded_src_path)
          fail "Only 'w' mode is supported for directories" if mode != 'w'
          fail 'ERB processing not supported for directories' if process_erb
          FileUtils.cp_r expanded_src_path, target_path
          return
        end
        src = File.read(expanded_src_path)
        src = eval_template(src) if process_erb
        FileUtils.mkdir_p(File.dirname(target_path))
        File.write target_path, src, mode: mode
      end

      def eval_template(src)
        ERB.new(src, nil, '-').result(binding)
      end

      def replace(path, pattern, replacement = nil, optional: false,
                  global: false)
        src = File.read(path)
        replace_method = global ? :gsub! : :sub!
        changed = if block_given?
                    src.send(replace_method, pattern) do |_|
                      yield Regexp.last_match
                    end
                  else
                    src.send(replace_method, pattern, replacement)
                  end
        unless changed || optional
          fail ThreddedCreateApp::CommandError,
               "No match found for #{pattern} in #{path}"
        end
        File.write path, src
        changed
      end

      def add_precompile_asset(asset)
        log_verbose "Add precompile asset: #{asset}"
        assets_conf = File.read('config/initializers/assets.rb')
        if assets_conf.include?('# Rails.application.config.assets.precompile')
          replace 'config/initializers/assets.rb',
                  /# Rails\.application\.config\.assets\.precompile.*/,
                  "Rails.application.config.assets.precompile += %w(#{asset})"
        else
          replace 'config/initializers/assets.rb',
                  /config\.assets\.precompile \+= %w\((.*?)\)/,
                  "config.assets.precompile += %w(\\1 #{asset})"
        end
      end

      def add_route(route_str, prepend: false)
        log_verbose "Add route: #{route_str}"
        inject_into_file 'config/routes.rb',
                         content: "#{"\n" unless prepend}  #{route_str}",
                         **(if prepend
                              { after: /\.routes\.draw do\s*\n/m }
                            else
                              { before: /\nend\n\z/ }
                            end)
      end

      def add_migration(name, content: nil, template: nil)
        run_generator "migration #{name}"
        replace Dir["db/migrate/*_#{name}.rb"][0],
                /^ *def change\n *end\n/,
                indent(2, content ||
                    eval_template(File.read(expand_src_path(template))))
      end

      def inject_into_file(path, content:, after: nil, before: nil)
        replace path, (after || before), after ? '\0' + content : content + '\0'
      end

      def indent(n, s)
        s.gsub(/^/, ' ' * n)
      end

      def run_generator(generate_args)
        run "bundle exec rails g #{generate_args}#{' --quiet' unless verbose?}"
      end

      def run(*args, log: true)
        if log
          log_command args.length == 1 ? args[0] : Shellwords.shelljoin(args)
        end
        exit 1 unless system(*args)
      end

      def verbose?
        @verbose
      end
    end
  end
end
