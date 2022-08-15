class AddRevisionToTurns < ActiveRecord::Migration[7.0]
  def change
    add_column :turns, :revision, :integer
  end
end
