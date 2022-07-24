# TODO

## MVP 2
- [ ] implement integration smoke tests
- [ ] implement game finished notification
- [ ] implement indefinite first and last turns
- [ ] implement cronjob for turn reminder notification
- [ ] implement cronjob for turn forfeit notification
- [ ] implement cronjob for game finished notification
- [ ] add :status field on :turns table - finished | forfeited
- [ ] remove Reform#full_messages_for monkey patch
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
- [ ] add version control (change requests)
- [ ] add :order field on :users table for random option (with no double-turns)

EtherPad-Lite implementation (development):
- [ ] allow branching of document
- [ ] allow change requests to be issued
- [ ] show diffs using [diffy](https://github.com/samg/diffy)
- [ ] allow voting on change requests
- [X] create node.js server for [EtherPad-Lite](https://github.com/ether/etherpad-lite)
- [X] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [X] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [X] show current game without ability to edit (for players whose turn it is not)
- [X] allow entry with EtherPad-Lite embedded with "End Turn" button (for players whose turn it is)
- [X] "End Turn" action saves the entire text as the entry and sends notification

Etherpad-Lite implementation (production):
- [ ] spin up new server for Etherpad and Lorem Ipsum
- [ ] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [ ] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [ ] create a simple deploy system
