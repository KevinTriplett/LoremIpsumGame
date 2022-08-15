class AddAuthorColorToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :author_color, :string
  end
end
