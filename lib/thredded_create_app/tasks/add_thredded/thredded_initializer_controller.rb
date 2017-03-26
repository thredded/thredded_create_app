# frozen_string_literal: true

Rails.application.config.to_prepare do
  Thredded::ApplicationController.module_eval do
    rescue_from Thredded::Errors::LoginRequired do |exception|
      flash.now[:notice] = exception.message
      render template: 'devise/sessions/new', status: :forbidden
    end
  end
end
