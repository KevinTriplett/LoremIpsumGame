require 'test_helper'

class UserTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  it "resets reminded flag" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      user.update(reminded: true)
      assert user.reminded?

      user.reset_reminded
      user.reload
      assert !user.reminded?
    end
  end

  it "reminds user" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game_id: game.id)
      user2 = create_game_user(game_id: game.id)
      assert !user1.reminded?
      assert !user2.reminded?

      ActionMailer::Base.deliveries.clear
      user1.remind
      assert_emails 1
      assert  user1.reminded?
      assert !user2.reminded?
      ActionMailer::Base.deliveries.clear
    end
  end

  it "auto finishes turn" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game_id: game.id)
      user2 = create_game_user(game_id: game.id)
      assert_equal 0, Turn.all.count

      ActionMailer::Base.deliveries.clear
      user1.finish_turn
      assert_emails 2
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      ActionMailer::Base.deliveries.clear
    end
  end
end