class AddEndedToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :started, :datetime
    add_column :games, :ended, :datetime
  end
end
