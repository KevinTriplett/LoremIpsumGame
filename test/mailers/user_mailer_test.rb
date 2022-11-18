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
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, 'Lorem Ipsum - Welcome to the Game'
      assert_match /here's your magic link/, email.body.encoded
      assert_match /#{get_magic_link(user)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
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
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, 'Lorem Ipsum - Sorry to see you go'
      assert_match /we understand/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'turn_notification' do
    DatabaseCleaner.cleaning do
      game = create_game({
        started: Time.now-1.day,
        round: 3,
        num_rounds: 7
      })
      user1 = create_game_user(game_id: game.id)
      user2 = create_game_user(game_id: game.id)
      user3 = create_game_user(game_id: game.id)

      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user1).turn_notification
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user1.email]
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
      assert_match /Here's your magic link/, email.body.encoded
      assert_no_match /played since your last turn, in order/, email.body.encoded
      assert_match /Round #{game.round} of #{game.num_rounds}/, email.body.encoded

      create_user_turn(user_id: user1.id)
      create_user_turn(user_id: user2.id)
      ActionMailer::Base.deliveries.clear
      email = UserMailer.with(user: user3).turn_notification
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user3.email]
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
      assert_match /Here's your magic link/, email.body.encoded
      assert_match /#{get_magic_link(user3)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(user3)}/, email.header['List-Unsubscribe'].inspect
      assert_match /<li>#{Regexp.quote(user1.name)}<\/li>\r\n<li>#{Regexp.quote(user2.name)}<\/li>/, email.body.encoded
      assert_match /Round #{game.round} of #{game.num_rounds}/, email.body.encoded
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
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Reminder: It's Your Turn"
      assert_match /Here's your magic link/, email.body.encoded
      assert_match /#{get_magic_link(user)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
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
      assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Your turn was finished for you"
      assert_no_match /#{user.name}/, email.body.encoded
      assert_no_match /#{get_magic_link(user)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
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
      assert_nil email.cc
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - It's Done! Time to Celebrate!"
      assert_match /Here's your magic link/, email.body.encoded
      assert_match /#{get_magic_link(user)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'group_alert' do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      params = {
        user: user,
        subject: "test subject",
        body: "my spoon is too big https://bigspoon.com"
      }
      email = UserMailer.with(params).group_alert
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to, [user.email]
      assert_nil email.cc
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - " + params[:subject]
      assert_equal email.body, params[:body]
      assert_match /https:\/\/bigspoon.com/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end
end