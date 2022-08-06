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

  desc "Simulates deleting unused Pads"
  task simulate_purge_pads: :environment do
    Game.delete_unused_pads(false)
  end

  desc "Deletes unused Pads"
  task purge_pads: :environment do
    Game.delete_unused_pads(true)
  end
end
