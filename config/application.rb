require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LoremIpsum
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    Rails.application.routes.default_url_options[:host] = 'loremipsumgame.com'

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.from_email_adr = "noreply@loremipsumgame.com"
    config.etherpad_api_key = Rails.env == "development" ?
      "49052a8e1b7526b24fcc46b8dfeb31bddc4cc5bc06dd0f93950cb1de6c374b92" :
      ENV["ETHERPAD_API_KEY"]
    config.etherpad_url = (Rails.env == 'production' ?
      'https://loremipsumgame.com' :
      'https://127.0.0.1') +
      ":9001"
    config.initial_etherpad_text = "Welcome to the Lorem Ipsum Game!"
    config.admin_name = (Rails.env == 'production' ?
      ENV["ADMIN_NAME"] : "admin")
    config.admin_password = (Rails.env == 'production' ?
      ENV["ADMIN_PASSWORD"] : "password")
    config.author_colors = [
      "#00FFFF", # vibrant colors
      "#FFFF00",
      "#99FF99",
      "#FFCC66",
      "#FF9900",
      "#FF00FF",
      "#0000FF",
      "#00FF00",
      "#606F82",
      "#FFF4CB",
      "#5D8EC1",
      "#D9849B",
      "#A9976F",
      "#56A8B3",
      "#91CCF1",
      "#F493F2"
    ]
  end
end
