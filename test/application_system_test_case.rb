require "test_helper"
require 'selenium-webdriver'
require 'webdrivers'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Capybara::Minitest::Assertions
  driven_by :selenium, using: :firefox, screen_size: [1400, 1400]
end
