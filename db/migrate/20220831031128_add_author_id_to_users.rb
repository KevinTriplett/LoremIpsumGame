class AddAuthorIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :author_id, :string
  end
end
