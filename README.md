# LoremIpsum

This is a collaborative storytelling game developed for experimentation with collective decision making.

The game is turn-based, each turn a player adds or edits the story (or passes).

Current status is MVP 2

## MVP 2

Requirements:

- Out of scope this round:
    - Constraints created using Google Sheet (same as MVP 1)
    - No user authentication, no authorization mechanism, only user tokens to access game
- In scope this round:
    - Admin page
        - Basic HTTP authentication
        - Game CRUD
            - Game name
            - Number of rounds
            - Hours per turn
            - Pause after X rounds (0 = no pause)
        - User CRUD
            - Name
            - Email
            - Admin? boolean (gets cc'd on emails)
            - Send email to user with game link
            - Create turn order (first in, first turn)
            - Returns to new form to add next player
    - Player page
        - Accessed using link sent in email, which identifies user via token
        - Sets cookie on user’s browser to identify user
        - Reject with informative message when visiting without link and without cookie
        - Page display, from top to bottom:
            - Game name
            - Link to tutorial video
            - Game round X of Y rounds
            - Turn ends datetime
            - Turn time remaining
            - Document
            - [List of players with current player highlighted]
    - Email notifications
        - Welcome to game
        - Your turn
        - Turn reminder (after half turn time elapses)
        - Turn ended automatically (after quarter turn time grace period)
        - Game paused
        - Game ended
