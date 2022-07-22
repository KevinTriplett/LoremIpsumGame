# TODO

## MVP 2
- [ ] implement integration smoke tests
- [ ] show game with entries
- [ ] allow entry to be added
- [ ] remove Reform#full_messages_for monkey patch
- [X] add admin namespace to routes: game creation, editing, deleting, user creation, editing, deleting
- [X] add unauthorized page
- [X] edit users assigned to game (delete/update)
- [X] get initial views working (form errors not working)
- [X] style forms
- [X] style views
- [X] enforce unique users for game

## MVP 3
- [ ] add collaborative editor like [EtherPad](https://github.com/ether/etherpad-lite)
- [ ] add version control (change requests)

EtherPad-Lite implementation:
- [X] create node.js server for [EtherPad-Lite](https://github.com/ether/etherpad-lite)
- [ ] install [ruby-etherpad-lite](https://github.com/jhollinger/ruby-etherpad-lite)
- [ ] install [etherpad-lite-jquery-plugin](https://github.com/ether/etherpad-lite-jquery-plugin)
- [ ] show current game without ability to edit (for players whose turn it is not)
- [ ] allow entry with EtherPad-Lite embedded with "End Turn" button (for players whose turn it is)
- [ ] "End Turn" action saves the entire text as the entry and sends notification
- [ ] allow branching of document
- [ ] allow change requests to be issued
- [ ] show diffs [diffy](https://github.com/samg/diffy)
- [ ] allow voting on change requests