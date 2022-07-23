class Turn::Cell::Index < Cell::ViewModel

  def show
    render # renders app/cells/turn/cell/show.haml
  end

  def game_name
    model.name
  end

  def users
    model.users
  end

  def current_player_id
    model.current_player_id
  end

  def story
    context[:story].gsub("\n", "<br>")
  end  

  def game_start
    model.game_start.strftime("%m %-d, %Y")
  end

  def game_end
    model.game_end.strftime("%m %-d, %Y")
  end

  def turn_start
    model.turn_start.strftime("%l:%M %P (%a %-m/%-d)")
  end

  def turn_end
    model.turn_end.strftime("%l:%M %P on (%a %-m/%-d)")
  end
end