require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Lobsters
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Requiring our app-specific config
    require Rails.root.join('extras', 'config')

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Raise an exception when using mass assignment with unpermitted attributes
    config.action_controller.action_on_unpermitted_parameters = :raise

    config.cache_store = :file_store, "#{config.root}/tmp/cache/"

    config.action_mailer.default_url_options = {
      host: Lobsters::Config[:domain],
      protocol: "https"
    }
    config.action_mailer.default_options = { from: %Q{"Wayfare" <no-reply@#{Lobsters::Config[:domain]}>} }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              "smtp.mandrillapp.com",
      port:                 587,
      enable_starttls_auto: true,
      user_name:            Lobsters::Config[:mandrill_user_name],
      password:             Lobsters::Config[:mandrill_api_key],
      authentication:       "login",
      domain:               "news.wayfare.io"
    }

    config.after_initialize do
      Rails.application.routes.default_url_options[:host] =
        Rails.application.domain
    end
  end
end

# disable yaml/xml/whatever input parsing
silence_warnings do
  ActionDispatch::ParamsParser::DEFAULT_PARSERS = {}
end

# define site name and domain to be used globally, can be overridden in
# config/initializers/production.rb
class << Rails.application
  def allow_invitation_requests?
    true
  end

  def domain
    Lobsters::Config[:domain] || "example.com"
  end

  def name
    Lobsters::Config[:site_name] || "News"
  end

  # used as mailing list prefix and countinual prefix, cannot have spaces
  def shortname
    name.downcase.gsub(/[^a-z]/, "-")
  end
end

require "#{Rails.root}/lib/monkey"
