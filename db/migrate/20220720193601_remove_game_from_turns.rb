class RemoveGameFromTurns < ActiveRecord::Migration[7.0]
  def change
    remove_column :turns, :game_id, :bigint
  end
end
