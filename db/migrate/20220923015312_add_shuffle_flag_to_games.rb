class AddShuffleFlagToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :shuffle, :boolean
  end
end
