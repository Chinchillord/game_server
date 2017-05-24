-module(player_response).
-export([read/1, response/2]).

read("CON-" ++ Data) ->
	%calc response here, since this is player data
	{player, Data};
read("LOG-" ++ Data) ->
	%pass information to login server
	{login, Data};
read( _Data ) ->
	unknown.

response(_ID, _Data) ->
	unknown.