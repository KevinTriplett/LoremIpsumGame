class AddTurns < ActiveRecord::Migration[7.0]
  def change
    create_table :turns do |t|
      t.text :entry
      t.references :user
      t.references :game
      t.timestamps
    end
  end
end
