require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Meet2code
  class Application < Rails::Application
    config.time_zone = 'Paris'

    config.i18n.default_locale = :fr
    config.i18n.available_locales = :fr

    ActiveSupport.halt_callback_chains_on_return_false = false
  end
end
