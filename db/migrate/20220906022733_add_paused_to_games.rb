class AddPausedToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :pause_rounds, :integer
    add_column :games, :paused, :boolean
  end
end
