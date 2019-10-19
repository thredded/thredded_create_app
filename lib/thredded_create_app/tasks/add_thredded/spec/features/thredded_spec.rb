# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Thredded', type: :feature do
  it 'root path responds with 200' do
    visit thredded.root_path
    expect(page.status_code).to be 200
  end
end
