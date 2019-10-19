# frozen_string_literal: true

require 'thredded_create_app/command_error'
require 'thredded_create_app/generator'
require 'thredded_create_app/logging'
require 'thredded_create_app/version'

require 'highline'
module ThreddedCreateApp
  class CLI # rubocop:disable Metrics/ClassLength
    include ThreddedCreateApp::Logging

    DEFAULTS = {
      auto_confirm: false,
      verbose: false,
      install_gem_bundler_rails: true,
      start_server: true,
      simple_form: true,
      database: :postgresql,
      rails_version: nil
    }.freeze

    def self.start(argv)
      new(argv).start
    end

    def initialize(argv)
      @argv = argv
    end

    def start
      auto_output_coloring do
        run
      rescue OptionParser::ParseError, ArgvError => e
        error e.message, 64
      rescue ThreddedCreateApp::CommandError => e
        begin
          error e.message, 78
        ensure
          log_verbose e.backtrace * "\n"
        end
      rescue Errno::EPIPE
        exit 1
      end
    rescue ExecutionError => e
      exit e.exit_code
    end

    private

    def run # rubocop:disable Metrics/AbcSize
      options = optparse
      generator = ThreddedCreateApp::Generator.new(options)
      log_info 'Will do the following:'
      log_info generator.summary
      exit unless options[:auto_confirm] || agree?
      generator.generate
      log_stderr Rainbow(<<~TEXT).green.bright
        All done! 🌟
      TEXT
      generator.run_tests! unless ENV['SKIP_TESTS']
      start_app_server!(options[:app_path]) if options[:start_server]
    end

    def start_app_server!(app_path)
      log_info 'Changing directory and starting the app server'
      command = "cd #{Shellwords.escape(app_path)} && " \
        'bundle exec rails s'
      log_command command
      if defined?(Bundler)
        Bundler.with_clean_env { exec command }
      else
        exec command
      end
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def optparse
      argv = @argv.dup
      argv << '--help' if argv.empty?
      options = DEFAULTS.dup
      positional_args = OptionParser.new(
        "Usage: #{program_name} #{Rainbow('APP_PATH').bright}", 37
      ) do |op|
        flags = Flags.new(op, options)

        db_adapters = %i[postgresql mysql2 sqlite3]
        op.on '--database DATABASE', db_adapters,
              "The database adapter, one of: #{db_adapters.join(', ')} " \
              "(default: #{DEFAULTS[:database]})" do |v|
          options[:database] = v.to_sym
        end

        op.on '--rails-version VERSION',
              'The exact version of Rails to use (default: latest)' do |value|
          options[:rails_version] = value
        end

        flags.bool :simple_form, '--[no-]simple-form', 'Use simple_form'

        op.separator "\nOther options:"
        flags.bool :start_server, '--[no-]start-server', 'Start the app server'
        flags.bool :install_gem_bundler_rails,
                   '--[no-]install-gem-bundler-rails',
                   'Run `gem update --system and `gem install bundler rails`'
        flags.bool :auto_confirm, '-y', 'Auto-confirm all prompts'
        flags.bool :verbose, '--verbose', 'Verbose output' do
          @verbose = true
        end
        op.on '-v', '--version', 'Print the version' do
          puts ThreddedCreateApp::VERSION
          exit
        end
        op.on '-h', '--help', 'Show this message' do
          STDERR.puts op
          exit
        end
        op.separator Rainbow(<<~TEXT).blue.bright
                 For more information, see the readme at:
          #{File.expand_path('../../README.md', File.dirname(__FILE__))}
          https://github.com/thredded/thredded_create_app
        TEXT
      end.parse!(argv)
      if positional_args.length != 1
        fail ArgvError, 'Expected 1 positional argument, ' \
                        "got #{positional_args.length}."
      end
      options.update(app_path: argv[0])
      options
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    class Flags
      def initialize(op, options)
        @op      = op
        @options = options
      end

      # rubocop:disable Style/OptionalArguments
      def bool(as, short = nil, long, desc)
        flag_args = [short, long].compact
        if long.start_with?('--[no-]')
          desc += " (default: #{DEFAULTS[as]})" if DEFAULTS[as]
          @op.on(*flag_args, desc) do |v|
            @options[as] = v
            yield v if block_given?
          end
        else
          @op.on(*flag_args, desc) do
            @options[as] = !long.start_with?('--no-')
            yield @options[as] if block_given?
          end
        end
      end
      # rubocop:enable Style/OptionalArguments
    end

    def error(message, exit_code)
      log_error message
      fail ExecutionError.new(message, exit_code)
    end

    def auto_output_coloring(coloring = STDOUT.isatty)
      coloring_was = Rainbow.enabled
      Rainbow.enabled = coloring
      HighLine.use_color = coloring
      yield
    ensure
      HighLine.use_color = coloring_was
      Rainbow.enabled = coloring_was
    end

    def agree?
      ::HighLine.new.agree(Rainbow('Proceed? [y/n]').yellow.bright, true)
    end

    def verbose?
      @verbose
    end

    class ArgvError < StandardError
    end

    class ExecutionError < RuntimeError
      attr_reader :exit_code

      def initialize(message, exit_code)
        super(message)
        @exit_code = exit_code
      end
    end
  end
end
