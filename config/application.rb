require File.expand_path('../boot', __FILE__)
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module BulSearch
  class Application < Rails::Application
    require 'constants'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    if Rails.env.production?
      config.secret_key_base = ENV['ESEARCH_KEY']
    else
      config.secret_key_base = '4c6ca96a55bc7dd6e00265ece6bdc52a979355784da9b0f3668fd53e130741ebe0c68240b669912684be4c9cff3f4d6424dee2453cf0f4115c20c7cef81cd216'
    end
  end
end
