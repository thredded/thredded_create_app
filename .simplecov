# frozen_string_literal: true
if ENV['COVERAGE'] && !%w(rbx jruby).include?(RUBY_ENGINE)
  if ENV['CI']
    require 'codeclimate_batch'
    require 'codeclimate-test-reporter'
    CodeClimate::TestReporter.configuration.git_dir = File.dirname(__FILE__)
    CodeclimateBatch.start
  else
    SimpleCov.start do
      formatter SimpleCov::Formatter::HTMLFormatter
    end
  end
end
