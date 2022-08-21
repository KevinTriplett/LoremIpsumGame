require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test 'welcome_email' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).welcome_email
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, '[Lorem Ipsum] Welcome to the Game 🤗'
      assert_match /here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'goodbye_email' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).goodbye_email
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, '[Lorem Ipsum] Sorry to see you go 😭'
      assert_match /we understand/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_notification' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).turn_notification
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn! 🥳"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_reminder' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).turn_reminder
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] Reminder: It's Your Turn 😅"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_auto_finished' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).turn_auto_finished
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] Your turn was finished for you 🫣"
      assert_no_match /#{user.name}/, email.body.encoded
      assert_no_match /#{get_magic_link(user)}/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'game_ended' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user).game_ended
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_equal email.cc, ["kt@kevintriplett.com"]
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "[Lorem Ipsum] It's Done! Time to Celebrate! 🎉"
      assert_match /Here's your magic link/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end
end