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
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table_name};" unless table_name == "ar_internal_metadata"
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
  @last_random_user_name = "#{ NAMES.sample } #{ SURNAMES.sample }"
end

def last_random_user_name
  @last_random_user_name
end


GAME_NAMES_FIRST = %w(dark lorem glad sad melancholy joyful lonesome tender lucid)
GAME_NAMES_CONJUNCT = %w(and in but for yet the)
GAME_NAMES_SECOND = %w(windy shiney crazy lovely stormy blissfully wispy wistfully)
GAME_NAMES_THIRD = %w(night ipsum song melody heart dove mercies dreams)
def random_game_name
  begin
    @_last_random_game_name = "#{ GAME_NAMES_FIRST.sample } #{ GAME_NAMES_CONJUNCT.sample } #{ GAME_NAMES_SECOND.sample } #{ GAME_NAMES_THIRD.sample }"
  end while Game.find_by_name(@_last_random_game_name)
  @_last_random_game_name
end

def last_random_game_name
  @_last_random_game_name
end

def create_game(params = {})
  Game.create(
    name: random_game_name,
    game_start: params[:game_start],
    game_end: params[:game_end],
    turn_start: params[:turn_start],
    turn_end: params[:turn_end],
    game_days: (params[:game_days] || Rails.configuration.default_game_days),
    turn_hours: (params[:turn_hours] || Rails.configuration.default_turn_hours),
    current_player_id: params[:current_player_id]
  )
end

def create_user(params = {})
  User.create(
    name: params[:name] || random_user_name,
    email: params[:email] || random_email,
    game_id: params[:game_id]
  )
end