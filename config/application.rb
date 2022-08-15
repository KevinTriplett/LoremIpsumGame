require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LoremIpsum
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.etherpad_api_key = Rails.env == "development" ?
      "49052a8e1b7526b24fcc46b8dfeb31bddc4cc5bc06dd0f93950cb1de6c374b92" :
      ENV["ETHERPAD_API_KEY"]
    config.etherpad_url = (Rails.env == 'production' ?
      'https://loremipsumgame.com' :
      'http://127.0.0.1') +
      ":9001"
    config.admin_name = (Rails.env == 'production' ?
      ENV["ADMIN_NAME"] : "admin")
    config.admin_password = (Rails.env == 'production' ?
      ENV["ADMIN_PASSWORD"] : "password")
  end
end
