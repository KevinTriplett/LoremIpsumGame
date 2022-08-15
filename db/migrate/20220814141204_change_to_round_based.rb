class ChangeToRoundBased < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :num_rounds, :integer
    add_column :games, :round, :integer
    remove_column :games, :game_start
    remove_column :games, :game_end
    remove_column :games, :game_days
    add_column :turns, :round, :integer
    add_column :turns, :game_id, :bigint
    add_column :users, :play_order, :integer
  end
end
