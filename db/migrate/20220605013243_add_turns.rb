class AddTurns < ActiveRecord::Migration[7.0]
  def up
    create_table :turns do |t|
      t.text :entry
      t.references :user
      t.references :game
      t.timestamps
    end
  end

  def down
    drop_table :turns
  end
end
