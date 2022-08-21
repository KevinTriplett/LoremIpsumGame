class LoremTaskTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  test "sends emails for reminders" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours - 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      LoremIpsum::Application.load_tasks
      Rake::Task['lorem:remind_players'].invoke
      assert_emails 2
      ActionMailer::Base.deliveries.clear
    end
  end

  test "auto finishes turns" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.hour - 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      LoremIpsum::Application.load_tasks
      Rake::Task['lorem:auto_finish_turns'].invoke
      assert_emails 4
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 1, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end
end