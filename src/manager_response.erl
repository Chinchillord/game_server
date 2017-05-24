-module(manager_response).
-export([respond/4]).


%Pass the player to the game
respond(Sender, RequestID, Data, State) ->
	State.