# frozen_string_literal: true
SimpleCov.start do
  add_filter '/spec/'
  formatter SimpleCov::Formatter::HTMLFormatter unless ENV['TRAVIS']
end
