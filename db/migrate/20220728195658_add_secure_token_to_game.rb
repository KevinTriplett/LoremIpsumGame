class AddSecureTokenToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :token, :string
    add_index :games, :token, unique: true
    remove_column :games, :pad_name
  end
end
