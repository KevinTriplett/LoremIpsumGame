namespace :lorem do
  desc "Remind players whose turns are half over"
  task remind_players: :environment do
    User.remind_players
  end
  
  desc "Auto finish turns that expired"
  task auto_finish_turns: :environment do
    User.auto_finish_turns
  end

  desc "Create a cli report for all games"
  task report: :environment do
    Game.generate_report
  end
end
