class AddPadNameToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :pad_name, :string
  end
end
