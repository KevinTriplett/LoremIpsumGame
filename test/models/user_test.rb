require 'test_helper'

class UserTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "resets reminded flag" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id, reminded: true)

      user.reload
      assert user.reminded?

      user.reset_reminded!
      user.reload
      assert !user.reminded?
    end
  end
end