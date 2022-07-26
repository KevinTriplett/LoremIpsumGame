class Game < ActiveRecord::Base
    has_many :users, dependent: :destroy
    has_one :current_player, class_name: "User"

    def last_turn?
        turn_end && game_end && turn_end > game_end
    end
end