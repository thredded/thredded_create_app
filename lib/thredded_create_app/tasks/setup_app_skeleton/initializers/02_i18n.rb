# frozen_string_literal: true

# Manually initialize i18n so that it can be used in the initializers
I18n::Railtie.initialize_i18n(Rails.application)
I18n.backend.send(:init_translations) unless I18n.backend.initialized?
