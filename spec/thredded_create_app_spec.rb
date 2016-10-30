# frozen_string_literal: true
require 'spec_helper'

describe ThreddedCreateApp do
  it 'has a version number' do
    expect(ThreddedCreateApp::VERSION).not_to be nil
  end

  it 'generates the app without errors' do
    expect(system('bin/create-tmp-myapp --verbose --no-start-server'))
      .to(be true)
    # TODO: Add tests to the app that check 200 status on home and forums and
    # run them here.
  end
end
