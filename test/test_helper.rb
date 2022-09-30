ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

############################
#
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 0)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
end

############################
# database cleaner
require 'database_cleaner/active_record'
DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with :truncation

############################
# SystemTestCase testing - needed?
# require 'capybara/rails'
# require 'capybara/minitest'
# Capybara.server = :puma, { Silent: true }

############################
# app-specific test helpers

NAMES = %w(john jane eric lee harvey sam kevin hank)
SURNAMES = %w(smith jones doe windsor johnson klaxine)
PROVIDERS = %w(gmail domain example sample yahoo gargole)
TLDS = %w(com it org club pl ru uk aus)
def random_email
  begin
    @_last_random_email = "#{ NAMES.sample }.#{ SURNAMES.sample }@#{ PROVIDERS.sample }.#{ TLDS.sample }"
  end while User.find_by_email(last_random_email)
  @_last_random_email
end

def last_random_email
  @_last_random_email
end

def random_user_name
  @_last_random_user_name = "#{ NAMES.sample } #{ SURNAMES.sample }"
end

def last_random_user_name
  @_last_random_user_name
end

GAME_NAMES_FIRST = %w(dark lorem glad sad melancholy joyful lonesome tender lucid)
GAME_NAMES_SECOND = %w(windy shiney crazy lovely stormy blissful wispy wistful)
GAME_NAMES_THIRD = %w(night ipsum song melody heart dove mercies dreams)
def random_game_name
  begin
    @_last_random_game_name = "#{ GAME_NAMES_FIRST.sample } #{ GAME_NAMES_SECOND.sample } #{ GAME_NAMES_THIRD.sample }"
  end while Game.find_by_name(last_random_game_name)
  @_last_random_game_name
end

def last_random_game_name
  @_last_random_game_name
end

def create_game(params = {})
  Game.create(
    name: params[:name] || random_game_name,
    started: params[:started],
    turn_start: params[:turn_start],
    turn_end: params[:turn_end],
    num_rounds: params[:num_rounds] || 10,
    turn_hours: (params[:turn_hours] || 48),
    current_player_id: params[:current_player_id],
    round: params[:round] || 1,
    pause_rounds: params[:pause_rounds] || 0,
    paused: params[:paused],
    shuffle: params[:shuffle],
    ended: params[:ended]
  )
end

def create_game_user(params)
  User::Operation::Create.call(
    params: {
      user: {
        name: params[:name] || random_user_name, 
        email: params[:email] || random_email,
        admin: params[:admin] || false
      }
    },
    game_id: params[:game_id]
  )[:model]
end

def create_user_turn(params)
  user = User.find(params[:user_id])
  Turn::Operation::Create.call(
    params: {
      turn: {},
      pass: params[:pass]
    },
    user_id: user.id,
    game_id: user.game_id
  )[:model]
end

def get_magic_link(user)
  "https://loremipsumgame.com/users/#{user.token}/turns/new"
end

def get_unsubscribe_link(user)
  "https://loremipsumgame.com/users/#{user.token}/unsubscribe"
end
