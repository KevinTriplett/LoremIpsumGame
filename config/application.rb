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
      "%2300FFFF", # vibrant colors
      "%23FFFF00",
      "%2399FF99",
      "%23FFCC66",
      "%23FF9900",
      "%23FF00FF",
      "%230000FF",
      "%2300FF00",
      "%23606F82",
      "%23FFF4CB",
      "%235D8EC1",
      "%23D9849B",
      "%23A9976F",
      "%2356A8B3",
      "%2391CCF1",
      "%23F493F2"
    ]
  end
end
