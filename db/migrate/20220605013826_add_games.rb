class AddGames < ActiveRecord::Migration[7.0]
  def up
    create_table :games do |t|
      t.string :name
      t.references :current_player
      t.datetime :turn_start
      t.datetime :turn_end
      t.datetime :game_start
      t.datetime :game_end
      t.timestamps
    end
  end

  def down
    drop_table :games
  end
end
