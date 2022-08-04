class Game < ActiveRecord::Base
  has_many :users, dependent: :destroy

  has_secure_token

  def current_player
    User.find(current_player_id)
  end

  def next_player_id
    # rollover if at the end of the user array
    (users.where("id > ?", current_player_id).first || users.first).id
  end

  def last_turn?
    turn_end && game_end && turn_end > game_end
  end

  def ended?
    game_end && Time.now > game_end
  end

  def no_reminder_yet?
    Time.now < (turn_end - turn_reminder_hours)
  end

  def no_auto_finish_yet?
    Time.now < (turn_end + grace_period_hours)
  end

  private

  def turn_reminder_hours
    (turn_hours / 2).hours
  end

  # TODO: can make this configurable on the model
  def grace_period_hours
    turn_hours / 4
  end

  def self.generate_report
    Game.all.each do |g|
      puts "Game: #{g.name}" + (g.ended? ? " [ended]" : "")
      puts "  #{g.users.count} players"
      unless g.ended?
        puts "  current_player: #{g.current_player ? g.current_player.name : "no player yet"}"
        puts "  turn_end: #{g.turn_end.iso8601} (#{g.turn_end.short_date_at_time})"
        puts "  game_end: #{g.game_end.iso8601} (#{g.game_end.short_date_at_time})"
        puts "  turn_hours: #{g.turn_hours}"
        g.users.each_with_index do |u, i|
          puts "  user #{i+1}:"
          puts "    name #{u.name}"
          puts "    turns count: #{u.turns.count}"
        end
      end
    end
  end
end