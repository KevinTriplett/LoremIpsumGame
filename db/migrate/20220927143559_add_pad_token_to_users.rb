class AddPadTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :pad_token, :string
  end
end
