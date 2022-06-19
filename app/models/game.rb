class Game < ActiveRecord::Base
    has_many :users, dependent: :destroy
    has_many :turns, dependent: :destroy
    has_one :current_player, class_name: "User"
end