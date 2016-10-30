# frozen_string_literal: true
require 'simplecov' if ENV['COVERAGE'] && !%w(rbx jruby).include?(RUBY_ENGINE)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'thredded_create_app'
