# frozen_string_literal: true
require 'spec_helper'

describe ThreddedCreateApp do
  it 'has a version number' do
    expect(ThreddedCreateApp::VERSION).not_to be nil
  end

  it 'generates the app without errors' do
    expect(system('bin/create-tmp-myapp --verbose --no-start-server'))
      .to(be true)
  end
end
