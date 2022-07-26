# require "test_helper"

# class AdminUserTest < ActionDispatch::IntegrationTest
#   DatabaseCleaner.clean

#   test "Admin page for user editing" do
#     DatabaseCleaner.cleaning do
#       game = create_game
#       user = create_user(game_id: game.id)

#       get edit_admin_game_user_path(game_id: game.id, id: user.id)
#       assert_select "h1", "Lorem Ipsum"
#       assert_select "h5", "Editing user"
#       assert_select "input#user_name[value='#{user.name}']", nil
#       assert_select "input#user_email[value='#{user.email}']", nil
#     end
#   end
# end
