class Game < ActiveRecord::Base
    has_many :users
    has_many :turns
    has_one :current_player, class_name: "User"
end