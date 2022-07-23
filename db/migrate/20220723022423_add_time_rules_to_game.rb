class AddTimeRulesToGame < ActiveRecord::Migration[7.0]
  def up
    add_column :games, :game_days, :integer
    add_column :games, :turn_hours, :integer
  end

  def down
     delete_column :games, :game_days
     delete_column :games, :turn_hours
  end
end
