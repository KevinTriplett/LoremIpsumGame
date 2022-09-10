# TODO

## MVP 2
- [ ] enable eager_loading in production (causes TRB issue)
- [ ] remove Reform#full_messages_for monkey patch
- [ ] fix js asset delivery
- [X] in turn notifications, give round X of Y message (and pause rounds)
- [X] remove the ability to delete authorship colors
- [X] fix etherpad not loading on page open
- [X] remove first and final turns indefinite
- [X] improve email notification when updating user
- [X] resume should send email to current user that it's their turn
- [X] include "round X of Y" in game play screen
- [X] implement game pause after N rounds and sends email to admins
- [X] fix user colors in Etherpad to be consistent between rounds
- [X] make nice background in css
- [X] try setting author per https://github.com/jhollinger/ruby-etherpad-lite
- [X] handle game creation when pad cannot be created
- [X] implement more edge case tests
- [X] system test for pass and ending game
- [X] test for game start and end (and ended?)
- [X] test for new user added not upsetting rounds and finished
- [X] why does shuffle players sometimes fail? (Expected: [0, 3, 1, 4, 2] Actual: [4, 2, 0, 3, 1])
- [X] allow game to end early when all players pass
- [X] save revisions when turn (first) finished
- [X] Game ends: this round (and remove "in")
- [X] fix invalid date on player view
- [X] list players on player view in play order
- [X] change the Etherpad initial text
- [X] make sure first user added to game gets a turn notification email
- [X] add button to emails and replace "magic link" with actual link
- [X] convert test helper create_user to use User::Operation::Create
- [X] install comments plugin for pads
- [X] fix js not triggering on initial page load
- [X] move User#remind and auto_finish to rake tasks for crontab
- [X] create a cronjob system
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
- [ ] show diffs using EtherPad diffs or [diffy](https://github.com/samg/diffy)
- [ ] add voting and change blocks (see design below) FIRST DO THIS ON MN USING POLLS
- [X] add collaborative editor like [EtherPad](https://github.com/ether/etherpad-lite)
- [X] add :play_order field on :users table for random option (with no double-turns)
- [X] remove game_days and add num_rounds for ending the game

EtherPad-Lite implementation:
- [ ] allow branching
- [ ] allow change requests (aka pull requests)
- [ ] allow voting on change requests
- [X] create node.js server for [EtherPad-Lite](https://github.com/ether/etherpad-lite)
- [X] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [X] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [X] show current game without ability to edit (for players whose turn it is not)
- [X] allow entry with EtherPad-Lite embedded with "End Turn" button (for players whose turn it is)
- [X] "End Turn" action saves the entire text as the entry and sends notification

DONE Server implementation (production):
- [X] spin up new server for Etherpad and Lorem Ipsum
- [X] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [X] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [X] create a simple deploy system
- [X] implement cron job for turn reminders and turn auto finish

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
- [ ] how to default the num_rounds and turn_hours attributes during create?
- [ ] when can I use def method(ctx, **) and def method(cts, :some_param, **)?
- [ ] is the view file for Turn::Cell::Story in the right directory?
- [ ] why I can't use model: kwarg in User::Operation::Index?
- [ ] why do I have to monkey patch the Reform@full_messages_for method?
- [ ] why can't I eager load in production?
- [ ] how to create transaction wrap?