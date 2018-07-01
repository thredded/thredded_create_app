# frozen_string_literal: true

module Users
  class SessionsController < ::Devise::SessionsController
    attr_accessor :response_options

    protected

    def sign_in_params
      super.reverse_merge(remember_me: true)
    end

    def serialize_options(resource)
      super.merge!(response_options || {})
    end
  end
end
