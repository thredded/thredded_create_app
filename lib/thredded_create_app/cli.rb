# frozen_string_literal: true
require 'thredded_create_app'
require 'highline'
module ThreddedCreateApp
  class CLI
    include ThreddedCreateApp::Logging

    def self.start(argv)
      new(argv).start
    end

    def initialize(argv)
      @argv = argv
    end

    def start # rubocop:disable Metrics/MethodLength
      auto_output_coloring do
        begin
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
      end
    rescue ExecutionError => e
      exit e.exit_code
    end

    private

    def run
      options = optparse
      generator = ThreddedCreateApp::Generator.new(options)
      log_info 'Will do the following:'
      log_info generator.summary
      exit unless options[:auto_confirm] || agree?
      generator.generate
    end

    def optparse # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      argv = @argv.dup
      argv << '--help' if argv.empty?
      options = {}
      positional_args = OptionParser.new(
        "Usage: #{program_name} #{Term::ANSIColor.bold 'APP_PATH'}"
      ) do |op|
        op.on('-y', 'Auto-confirm all prompts') do
          options[:auto_confirm] = true
        end
        op.on('-v', '--version', 'Print the version') do
          puts ThreddedCreateApp::VERSION
          exit
        end
        op.on('--verbose', 'Verbose output') do
          ::ThreddedCreateApp.verbose = true
        end
        op.on('-h', '--help', 'Show this message') do
          STDERR.puts op
          exit
        end
        op.separator Term::ANSIColor.bright_blue <<-TEXT

For more information, see the readme at:
    #{File.expand_path('../../README.md', File.dirname(__FILE__))}
    https://github.com/thredded/thredded_create_app
TEXT
      end.parse!(argv)
      if positional_args.length != 1
        raise ArgvError, 'Expected 1 positional argument, ' \
                        "got #{positional_args.length}."
      end
      options.update(app_path: argv[0])
      options
    end

    def error(message, exit_code)
      log_error message
      raise ExecutionError.new(message, exit_code)
    end

    def auto_output_coloring(coloring = STDOUT.isatty)
      coloring_was             = Term::ANSIColor.coloring?
      Term::ANSIColor.coloring = coloring
      HighLine.use_color       = coloring
      yield
    ensure
      HighLine.use_color       = coloring_was
      Term::ANSIColor.coloring = coloring_was
    end

    def agree?
      ::HighLine.new.agree(
        Term::ANSIColor.bold(Term::ANSIColor.bright_yellow('Proceed? [y/n]')),
        true
      )
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
