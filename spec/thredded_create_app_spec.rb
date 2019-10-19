# frozen_string_literal: true

require 'spec_helper'

describe ThreddedCreateApp do
  it 'has a version number' do
    expect(ThreddedCreateApp::VERSION).not_to be nil
  end

  it 'generates the app without errors' do # rubocop:disable RSpec/ExampleLength
    Bundler.with_original_env do
      expect(system({ 'THREDDED_CREATE_APP_BIN_SIMPLECOV_COVERAGE' => '1',
                      'DB' => ENV['DB'],
                      'TRAVIS' => ENV['TRAVIS'] },
                    'bin/create-tmp-myapp --verbose --no-start-server'))
        .to(be true)
    end
  end
end
