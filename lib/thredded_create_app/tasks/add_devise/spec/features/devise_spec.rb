# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Devise', type: :feature do
  it 'sign in path responds with 200' do
    visit new_user_session_path
    expect(page.status_code).to be 200
  end
end
