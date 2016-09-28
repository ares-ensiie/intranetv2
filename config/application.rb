require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Intranet
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.to_prepare do
      # Only Applications list
      Doorkeeper::ApplicationsController.layout "application"

      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "fullscreen"

      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout "application"
    end
    config.time_zone = 'Europe/Paris'
    config.active_record.default_timezone = :local

    config.action_mailer.default_url_options = { 
      :host => 'ares-ensiie.eu' 
    } 
    config.action_mailer.delivery_method = :smtp 
    config.action_mailer.perform_deliveries = true 
    config.action_mailer.default :charset => "utf-8" 
    ActionMailer::Base.smtp_settings = { 
      :authentication => :plain,
      :address => "smtp.mailgun.org", 
      :port => 587, 
      :domain => ENV['MAILGUN_DOMAIN'] || 'sandboxea501c9c020041a7ae37953a23e0a476.mailgun.org', 
      :user_name => ENV['MAILGUN_USER'] || 'postmaster@sandboxea501c9c020041a7ae37953a23e0a476.mailgun.org', 
      :password => ENV['MAILGUN_PWD'] || 'bbd002600c6b8cb2cebaa5a107f1644e' 
    }
  end
end