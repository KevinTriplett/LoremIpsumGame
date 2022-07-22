class Turn::Cell::Show < Cell::ViewModel
  property :game
  property :user

  def show
    render # renders app/cells/turn/cell/show.haml
  end

  def story
    # get etherpad contents via ruby client
    "This is where the story will go"
  end
end