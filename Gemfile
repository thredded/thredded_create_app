# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'byebug', platform: :mri
if ENV['LOCAL_THREDDED']
  ENV['LOCAL_THREDDED'] = File.expand_path(ENV['LOCAL_THREDDED'])
  gem 'thredded', path: ENV['LOCAL_THREDDED']
end

eval_gemfile File.expand_path('rubocop.gemfile', __dir__)
