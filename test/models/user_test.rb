require 'test_helper'

class UserTest < MiniTest::Spec
  include ActionMailer::TestHelper
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

  it "reminds users of turns when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours - 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.remind_players
      assert_emails 2
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count

      assert user1.reminded?
      assert user3.reminded?
      assert !user2.reminded?
      assert !user4.reminded?
    end
  end

  it "does not remind users of turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours + 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.remind_players
      assert_emails 0

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count

      assert !user1.reminded?
      assert !user3.reminded?
      assert !user2.reminded?
      assert !user4.reminded?
    end
  end

  it "auto finishes turns when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.auto_finish_turns
      assert_emails 2
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 1, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end

  it "does not auto finish turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.auto_finish_turns
      assert_emails 0

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end
end