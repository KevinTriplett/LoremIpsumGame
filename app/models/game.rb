class Game < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :turns, dependent: :destroy

  has_secure_token

  def players
    users.order(play_order: :asc)
  end

  def current_player
    User.find(current_player_id)
  end

  def get_admins
    users.where(admin: true)
  end

  def resume
    update(paused: nil)
    UserMailer.with(user: current_player).turn_notification.deliver_now
  end

  def ended?
    !ended.nil?
  end

  def turns_this_round
    turns.where(round: round)
  end

  def next_player_id
    user_ids = players.pluck(:id) # use play_ordered collection
    i = user_ids.index(current_player_id)
    # rollover if at the end of the player array
    user_ids[i+1 < user_ids.count ? i+1 : 0]
  end

  def round_finished?
    turns_this_round.count == users.count
  end

  def players_finished?
    return false if turns.count < users.count
    users.all? do |u|
      turn = u.turns.order(id: :desc).first
      turn && turn.entry == "pass"
    end
  end

  def no_passes_this_round?
    !turns_this_round.any? {|t| t.entry == "pass"}
  end

  def get_who_played_since(user)
    user_last_turn_id = user.turns.count == 0 ? 0 : user.turns.order(id: :asc).last.id
    turns.order(id: :asc).where("id > ?", user_last_turn_id).collect do |t|
      t.user.name + (t.entry == 'pass' ? ' (passed)' : '')
    end
  end

  # [0, 1, 2, 3, 4]
  # [0, 3, 1, 4, 2] = in
  # [1, 0, 4, 3, 2] = out
  # [1, 3, 0, 2, 4] = in
  # [0, 1, 2, 3, 4] = out
  #
  # [0, 1, 2, 3, 4, 5]
  # [0, 3, 1, 4, 2, 5] = in
  # [4, 0, 2, 3, 5, 1] = out
  # [4, 3, 0, 5, 2, 1] = in
  # [5, 4, 2, 3, 1, 0] = in
  # [5, 3, 4, 1, 2, 0] = out
  # [1, 5, 2, 3, 0, 4] = in
  def shuffle_players
    return unless shuffle? && users.count > 2
    io = (round % 2 == 0) # alternate in/out shuffle each round (in => true)
    npo, opo = [], players.pluck(:id) # new play order, old play order
    i, mid = 0, (opo.count / 2) + (io ? opo.count % 2 : 0)
    while npo.count < opo.count
      npo.push(io ? opo[i] : opo[mid+i])
      npo.push(io ? opo[mid+i] : opo[i]) if npo.count < opo.count
      i += 1
    end
    users.each { |u| u.update(play_order: npo.index(u.id)) }
  end

  def time_to_remind_player?
    turn_end && Time.now > (turn_end - turn_reminder_hours)
  end

  def time_to_finish_turn?
    turn_end && Time.now > (turn_end + grace_period_hours)
  end

  def remind_current_player
    current_player.remind unless ended? || !time_to_remind_player?
    end

  def auto_finish_turn
    current_player.finish_turn unless ended? || !time_to_finish_turn?
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
    order(id: :asc).all.each(&:remind_current_player)
  end

  def self.auto_finish_turns
    order(id: :asc).all.each(&:auto_finish_turn)
  end  

  def self.generate_report
    puts "#{Game.all.count} games total"
    puts "#{User.all.count} users total"
    puts "#{Turn.all.count} turns total"
    Game.all.each do |g|
      puts "Game: #{g.name}"
      puts "  started: #{g.started.nil? ? " (not started yet)" : g.started.short_date_at_time}"
      puts "  ended: #{g.ended.nil? ? " (not ended yet)" : g.ended.short_date_at_time}"
      puts "  #{g.users.count} players"
      unless g.ended?
        rounds = game.num_rounds - game.round
        puts "  current_player: #{g.current_player ? g.current_player.name : "no player yet"}"
        puts "  current round: #{game.round}"
        puts "  game_ends: in #{ pluralize(rounds, "round") }"
        puts "  turn_hours: #{g.turn_hours}"
        if g.turn_end
          time = g.turn_time_remaining 
          puts "  turn_end: #{g.turn_end.iso8601} (#{g.turn_end.short_date_at_time})"
          puts "  remaining: #{time[:hours]} hours, #{time[:minutes]} minuutes"
        end
        g.players.each do |u|
          puts "  user #{user.play_order}:"
          puts "    name #{u.name}"
          puts "    turns count: #{u.turns.count}"
          puts "    last round played: #{u.turns.last.round}"
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