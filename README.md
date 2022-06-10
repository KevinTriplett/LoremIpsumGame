# LoremIpsum

This is a collaborative storytelling game developed for experimentation with collective decision making.

Current status is MVP 2

## MVP 2

Requirements:

- Out of scope this round:
    - Constraints created using Google Sheet (same as MVP 1)
    - No editing of existing paragraphs, only adding paragraphs
    - Attractive styling of presentation (not necessarily ugly, just don’t spend time yet on making it attractive and polished)
    - No authentication, no authorization mechanism
- In scope this round:
    - Admin page
        - Create new game
            - Reference only the most recently created game (no other selection mechanism)
            - CRUD manually using database CLI
        - Create user with email address
            - Save will:
                - Send email to user with game link
                - Create turn order (first in, first turn)
                - Returns to same page to add next player
            - CRUD manually using database CLI
    - Player page
        - Accessed using link sent in email, which identifies user
        - Sets cookie on user’s browser to identify user
        - Reject with informative message when visiting without link and without cookie
            - Information is to use the link from the email
            - If that email is lost, admins can reconstruct the link using the player id in the database (http://loremipsumgame.com/id=13)
        - Page display, from top to bottom:
            - Link to constraints Google Sheet
            - Link to EC post for discussion
            - Current story
            - Entry textbox with Submit button
                - Only show if it’s the player’s turn
                - Display current count / max
            - Turn time remaining
            - Game start date and end date
            - [List of players with current player highlighted]
    - Email notifications
        - Current turn ending warning (crontab job hourly, email sent at mid-point of turn):
            - Subject: [Lorem Ipsum] turn reminder
            - Body:
                - Hello! Your turn will end soon 😉
                - Here’s a link to the game: <link>
                - Here’s the story so far:
                    - story
        - Next player turn begins (triggered by entry submitted by previous player):
            - Subject: [Lorem Ipsum] turn notification
            - Body:
                - Hello! It’s your turn 😀
                - Here’s a link to the game: <link>
                - Here’s the new text [by player X]
                - Here’s the story so far:
                    - story
- Database schema
    - Player has
        - name [string]
        - email [string]
        - game [reference]
        - (Primary key is turn order)
    - Game has
        - name [string]
        - current_player [reference]
        - game_start [datetime]
        - game_end [datetime]
        - turn_start [datetime]
        - turn_end [datetime]
    - Turn has
        - entry [text]
        - player [reference]
        - game [reference]