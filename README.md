AI-server
---------
This is an experimental project which aims to provide a websocket server that hosts
simple turn-based games.
The basic structure of a game is:
+ a game class
++ acts as the referee
++ enforces all game rules
+ a list of players

So the basic order of events would be:
+ Player 1 initiates a game
++ Establish the connection
++ Issue a new game command
+++ Requires the name of the game class
++ The server sends back a game identifier
++ Registers its own connection as "player 1" for that game identifier
+ Player 1 sends a messages (IM, email, etc) with the game identifier to player 2
+ Player 2 joins the game
++ establishes a connection to the game server
++ registers its connection as the 'player 2'
+++ requires the game id generated by the server
+ The game class starts issuing messages to the clients
