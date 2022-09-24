require 'test_helper'

class GameMailerTest < ActionMailer::TestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test 'pause_notification with admins' do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game_id: game.id, admin: true)
      user2 = create_game_user(game_id: game.id)
      user3 = create_game_user(game_id: game.id, admin: true)
      ActionMailer::Base.deliveries.clear
      email = GameMailer.with(game: game).pause_notification
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to.to_set, [user1.email, user3.email].to_set
      assert_nil email.cc
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Game paused"
      assert_match /#{Regexp.quote(game.name)}/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end

  test 'pause_notification without admins' do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game_id: game.id)
      user2 = create_game_user(game_id: game.id)
      user3 = create_game_user(game_id: game.id)
      ActionMailer::Base.deliveries.clear
      email = GameMailer.with(game: game).pause_notification
      assert_emails 1 do
        email.deliver_now
      end

      assert_equal email.to.to_set, [user1.email, user2.email, user3.email].to_set
      assert_nil email.cc
      assert_nil email.bcc
      assert_equal email.from, ['noreply@loremipsumgame.com']
      assert_equal email.subject, "Lorem Ipsum - Game paused"
      assert_match /#{Regexp.quote(game.name)}/, email.body.encoded
      ActionMailer::Base.deliveries.clear
    end
  end
end