ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Destroy all models because they do not get destroyed automatically
(ActiveRecord::Base.connection.tables - %w{schema_migrations}).each do |table_name|
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table_name};"
end

NAMES = %w(john jane eric lee harvey sam kevin hank)
SURNAMES = %w(smith jones doe windsor johnson klaxine)
PROVIDERS = %w(gmail domain example sample yahoo gargole)
TLDS = %w(com it org club pl ru uk aus)
def random_email
  @_last_random_email = "#{ NAMES.sample }.#{ SURNAMES.sample }@#{ PROVIDERS.sample }.#{ TLDS.sample }"
end

def last_random_email
  @_last_random_email
end

def random_user_name
  "#{ NAMES.sample } #{ SURNAMES.sample }"
end


GAME_NAMES_FIRST = %w(dark lorem glad sad melancholy joyful lonesome tender lucid)
GAME_NAMES_SECOND = %w(night ipsum song melody heart dove mercies dreams)
def random_game_name
  @_last_random_game_name = "#{ GAME_NAMES_FIRST.sample } #{ GAME_NAMES_SECOND.sample }"
end

def last_random_game_name
  @_last_random_game_name
end

def create_game
  Game.create(name: random_game_name)
end

def create_user(game_id)
  User.create(name: random_user_name, email: random_email, game_id: game_id)
end