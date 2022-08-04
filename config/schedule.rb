# Examples:
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :output, "/home/deploy/LoremIpsum/current/log/cron.log"

every 1.hour do
  rake "lorem:remind_players"
  rake "lorem:auto_finish_turns"
end