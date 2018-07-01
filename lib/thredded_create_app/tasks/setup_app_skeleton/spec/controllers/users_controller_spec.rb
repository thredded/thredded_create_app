# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    let(:valid_attributes) do
      {
        display_name: 'Gleb',
        email: 'test@test.com',
        password: '123456',
        password_confirmation: '123456'
      }
    end

    it 'returns http success' do
      user = User.create(valid_attributes)
      get :show, params: { id: user.id }
      expect(response).to be_successful
    end
  end
end
