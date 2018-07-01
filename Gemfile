# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in thredded_create_app.gemspec
gemspec

gem 'byebug', platform: :mri

if ENV['CI']
  group :test do
    # CodeClimate coverage reporting.
    gem 'codeclimate-test-reporter', '>= 1.0.8', require: false
  end
end

if ENV['TRAVIS']
  # Add the generated app gems so that they are cached.
  gem 'bundler'
  gem 'capybara'
  gem 'coffee-rails'
  gem 'devise'
  gem 'devise-i18n'
  gem 'jbuilder'
  gem 'listen', '~> 3.0.8'
  gem 'mysql2' if ENV['DB'] == 'mysql2'
  gem 'pg' if ENV['DB'] == 'postgresql'
  gem 'puma'
  gem 'rails'
  gem 'rspec-rails'
  gem 'rubygems-update'
  gem 'sassc-rails'
  gem 'simple_form'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'sqlite3' if ENV['DB'] == 'sqlite3'
  gem 'thredded' unless ENV['LOCAL_THREDDED']
  gem 'turbolinks'
  gem 'uglifier'
  gem 'web-console'
end

# rubocop:disable Rubocop/DuplicatedGem
if ENV['LOCAL_THREDDED']
  ENV['LOCAL_THREDDED'] = File.expand_path(ENV['LOCAL_THREDDED'])
  gem 'thredded', path: ENV['LOCAL_THREDDED']
end
# rubocop:enable Rubocop/DuplicatedGem
