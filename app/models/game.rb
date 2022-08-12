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

  def time_to_remind_player?
    turn_end && Time.now > (turn_end - turn_reminder_hours)
  end

  def time_to_finish_turn?
    turn_end && Time.now > (turn_end + grace_period_hours)
  end

  def remind_current_player
    current_player.remind if !ended? && time_to_remind_player?
  end

  def auto_finish_turn
    current_player.finish_turn if !ended? && !last_turn? && time_to_finish_turn?
  end

  def turn_time_remaining
    {
      hours: (turn_end - Time.now).to_i/60/60.floor,
      minutes: ((turn_end - Time.now).to_f/60 % 60).floor
    }
  end

  private

  def turn_reminder_hours
    (turn_hours / 2).hours
  end

  # TODO: can make this configurable on the model
  def grace_period_hours
    (turn_hours / 4).hours
  end

  # class methods

  # class methods executed by cron job
  def self.remind_current_players
    all.each(&:remind_current_player)
  end

  def self.auto_finish_turns
    all.each(&:auto_finish_turn)
  end  

  def self.generate_report
    puts "#{Game.all.count} games total"
    puts "#{User.all.count} users total"
    puts "#{Turn.all.count} turns total"
    Game.all.each do |g|
      puts "Game: #{g.name}" + (g.ended? ? " [ended]" : "")
      puts "  #{g.users.count} players"
      unless g.ended?
        time = g.turn_time_remaining
        puts "  current_player: #{g.current_player ? g.current_player.name : "no player yet"}"
        puts "  game_end: #{g.game_end.iso8601} (#{g.game_end.short_date_at_time})"
        puts "  turn_end: #{g.turn_end.iso8601} (#{g.turn_end.short_date_at_time})"
        puts "  remaining: #{time[:hours]} hours, #{time[:minutes]} minuutes"
        puts "  turn_hours: #{g.turn_hours}"
        g.users.each_with_index do |u, i|
          puts "  user #{i+1}:"
          puts "    name #{u.name}"
          puts "    turns count: #{u.turns.count}"
          puts "    reminded: #{u.reminded? ? "yes" : "no"}"
        end
      end
    end
  end

  def self.delete_unused_pads(del)
    game_pads = Game.all.collect(&:token)
    puts "---------------"
    puts "active game_pads: #{game_pads.inspect}"
    puts "---------------"

    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    pads = client.listAllPads
    pads[:padIDs].each do |pad_name|
      if game_pads.include? pad_name
        puts (del ? "keeping" : "will keep") + " pad #{pad_name}"
      else
        puts (del ? "deleting" : "will delete") + " pad #{pad_name}"
        client.deletePad(padID: pad_name) if del
      end
    rescue => detail
      puts "could not get or delete pad '#{pad_name}':"
      puts detail.to_s
    end
  end
end