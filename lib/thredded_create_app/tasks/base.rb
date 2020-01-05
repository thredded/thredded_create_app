# frozen_string_literal: true

require 'shellwords'
require 'fileutils'
require 'erb'
require_relative '../logging'
require_relative '../command_error'
require_relative '../run_command'

module ThreddedCreateApp
  module Tasks
    # @abstract
    class Base
      include ThreddedCreateApp::Logging
      include ThreddedCreateApp::RunCommand

      attr_reader :app_name, :app_hostname, :app_path, :gems

      def initialize( # rubocop:disable Metrics/ParameterLists
        app_path:, verbose: false, database:, webpack_js: true,
        simple_form: true, **_args
      )
        @app_path = app_path
        @app_name = File.basename(File.expand_path(app_path))
        @app_hostname = "#{@app_name.tr(' ', '_').downcase}.com"
        @verbose = verbose
        @database_adapter_name = database.to_s
        @gems = []
        @simple_form = simple_form
        @webpack_js = webpack_js
      end

      def webpack_js?
        @webpack_js
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
        log_verbose "Add asset to manifest: #{asset}"
        append_to_file 'app/assets/config/manifest.js', "//= link #{asset}\n"
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

      def append_to_file(path, content)
        File.write(path, File.read(path) + content)
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

      def verbose?
        @verbose
      end
    end
  end
end
