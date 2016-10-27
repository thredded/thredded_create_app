# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in thredded_create_app.gemspec
gemspec

gem 'byebug', platform: :mri

if ENV['TRAVIS']
  # On Travis, add the generated app gems so that they are cached
  gem 'rails'
  gem 'sassc'
  gem 'thredded'
end
