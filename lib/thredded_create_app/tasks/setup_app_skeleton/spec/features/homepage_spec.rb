# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Homepage', type: :feature do
  it 'responds with 200' do
    visit root_path
    expect(page.status_code).to be 200
  end
end
