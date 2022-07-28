class Turn < ActiveRecord::Base
  belongs_to :user
  has_one :game, through: :user #, autosave: false (see https://stackoverflow.com/a/15649020/1204064)
end