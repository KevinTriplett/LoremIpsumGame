require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test 'welcome_email' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.welcome_email(user)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.bcc, ["kt@kevintriplett.com"]
      assert_equal email.from, ['notifications@loremipsumgame.com']
      assert_equal email.subject, '[Lorem Ipsum] Welcome to the Game'
      assert_match /here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_notification' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.turn_notification(user)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.bcc, ["kt@kevintriplett.com"]
      assert_equal email.from, ['notifications@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn!"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_reminder' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.turn_reminder(user)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.bcc, ["kt@kevintriplett.com"]
      assert_equal email.from, ['notifications@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] Reminder: It's Your Turn"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'game_ended' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.game_ended(user)
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.bcc, ["kt@kevintriplett.com"]
      assert_equal email.from, ['notifications@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] It's Done! Time to Celebrate!"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end
end