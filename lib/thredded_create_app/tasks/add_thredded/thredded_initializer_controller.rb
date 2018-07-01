# frozen_string_literal: true

Rails.application.config.to_prepare do
  Thredded::ApplicationController.module_eval do
    rescue_from Thredded::Errors::LoginRequired do |exception|
      flash.now[:notice] = exception.message
      controller = Users::SessionsController.new
      controller.request = request
      controller.request.env['devise.mapping'] = Devise.mappings[:user]
      controller.response = response
      controller.response_options = { status: :forbidden }
      controller.process(:new)
    end
  end
end
