class IncreaseTurnEntryLimit < ActiveRecord::Migration[7.0]
  def up
    # 16.megabytes is for mySQL MEDIUMTEXT
    # postgresql text field is unlimited
    change_column :turns, :entry, :text, limit: 16.megabytes - 1
  end
  def down
    # 10000 words per short story * 5 letters per word * 2
    change_column :turns, :entry, :text
  end
end
