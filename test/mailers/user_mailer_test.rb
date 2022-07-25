require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActionMailer::TestHelper

  test 'welcome_email' do
    game = create_game
    user = create_user(game_id: game.id)
    ActionMailer::Base.deliveries.clear
    email = UserMailer.welcome_email(user)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal email.to, [user.email]
    assert_equal email.from, ['notifications@loremipsumgame.com']
    assert_equal email.subject, '[Lorem Ipsum] Welcome to the Game'
    assert_match /here's your magic link/, email.body.encoded
    ActionMailer::Base.deliveries.clear
  end

  test 'turn_notification' do
    game = create_game
    user = create_user(game_id: game.id)
    ActionMailer::Base.deliveries.clear
    email = UserMailer.turn_notification(user)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal email.to, [user.email]
    assert_equal email.from, ['notifications@loremipsumgame.com']
    assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn!"
    assert_match /Here's your magic link/, email.body.encoded
    ActionMailer::Base.deliveries.clear
  end

  test 'turn_reminder' do
    game = create_game
    user = create_user(game_id: game.id)
    ActionMailer::Base.deliveries.clear
    email = UserMailer.turn_reminder(user)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal email.to, [user.email]
    assert_equal email.from, ['notifications@loremipsumgame.com']
    assert_equal email.subject, "[Lorem Ipsum] Reminder: It's Your Turn"
    assert_match /Here's your magic link/, email.body.encoded
    ActionMailer::Base.deliveries.clear
  end
end