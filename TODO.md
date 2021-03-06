# TODO

## MVP 2
- [ ] enable eager_loading in production (causes TRB issue)
- [ ] remove Reform#full_messages_for monkey patch
- [ ] fix js asset delivery
- [ ] create a cronjob system
- [X] remove player view inline script, put padID in dataset
- [X] display times in browser in user's timezone
- [X] add token to game and use for pad ID
- [X] create pad on game creation and delete on deletion
- [X] make pad_name static (can change game name and not change pad name)
- [X] implement integration system tests
- [X] convert to databasecleaner transactions
- [X] send email bcc to kt@kevintriplett.com
- [X] send game finished notification
- [X] implement indefinite last turn
- [X] implement integration smoke tests
- [X] deleting user reassigns current_player_id if necessary
- [X] implement game finished notification
- [X] implement indefinite first turn
- [X] implement cronjob for turn reminder notification
- [X] implement cronjob for turn forfeit notification
- [X] implement turn finished notification
- [X] update game/turn end datetimes when rules are updated
- [X] allow entry to be added
- [X] show game with entries
- [X] add admin namespace to routes: game creation, editing, deleting, user creation, editing, deleting
- [X] add unauthorized page
- [X] edit users assigned to game (delete/update)
- [X] get initial views working (form errors not working)
- [X] style forms
- [X] style views
- [X] enforce unique users for game

## MVP 3
- [X] add collaborative editor like [EtherPad](https://github.com/ether/etherpad-lite)
- [ ] add voting and change blocks (see design below)
- [ ] add :order field on :users table for random option (with no double-turns)

EtherPad-Lite implementation (development):
- [ ] allow branching of document
- [ ] allow change requests to be issued
- [ ] show diffs using EtherPad diffs or [diffy](https://github.com/samg/diffy)
- [ ] allow voting on change requests
- [X] create node.js server for [EtherPad-Lite](https://github.com/ether/etherpad-lite)
- [X] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [X] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [X] show current game without ability to edit (for players whose turn it is not)
- [X] allow entry with EtherPad-Lite embedded with "End Turn" button (for players whose turn it is)
- [X] "End Turn" action saves the entire text as the entry and sends notification

Server implementation (production):
- [X] spin up new server for Etherpad and Lorem Ipsum
- [ ] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [ ] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [ ] create a simple deploy system

EtherPad plugins worth looking at:
comments (https://www.npmjs.com/package/ep_comments_page)
voting wip (https://github.com/citizenos/ep_inline_voting)
who did what blame (https://www.npmjs.com/package/ep_who_did_what)
what have I missed (https://www.npmjs.com/package/ep_what_have_i_missed)
timeslider diff (https://www.npmjs.com/package/ep_timesliderdiff)
headings (https://www.npmjs.com/package/ep_headings2)

Voting and Change Blocks (feature request from David):
- [ ] show all changes made since player's last turn
- [ ] navigate to prev/next change
- [ ] provide up/down voting buttons (emojis that can be clicked with array of author ids)
- [ ] create this outside of Etherpad

## TRB QUESTIONS FOR NICK
- [ ] how to default the game_days and turn_hours attributes during create?
- [ ] when can I use def method(ctx, **) and def method(cts, :some_param, **)?
- [ ] is the view file for Turn::Cell::Story in the right directory?
- [ ] why I can't use model: kwarg in User::Operation::Index?