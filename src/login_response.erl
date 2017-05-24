-module(login_response).
-export([respond/4, login/2]).

-record(state, {player_serv=nil,player_count=nil, player_limit=nil, game=nil}).

%make sure the request is validly formed
respond(Sender, RequestID, "LGN:" ++ Data, State) when erlang:is_list(Data) ->
	Regex = "^(.*),(.*)$",
	io:format(Data ++ "\n"),
	case re:run(Data,Regex) of
		{match,[_Total,{UserStart,UserLen},{PassStart,PassLen}]} ->
			Password = lists:sublist(Data,PassStart+1,PassLen),
			Username = lists:sublist(Data,UserStart+1,UserLen),
			case login(Username,Password) of
				ok ->
					gen_server:cast(Sender,{client_reply, RequestID,"Hiya"}),
					State;
				failed ->
					gen_server:cast(Sender,{client_reply, RequestID, "Invalid Password"}),
					State
			end;
		nomatch ->
			State
	end;

%Pass the player to the game
respond(Sender, RequestID, "PLY", State = #state{game=Manager}) ->
	gen_server:cast(Sender,{state_change,Manager,play,{client_reply,RequestID,"Joining Game"}}),
	State.

%check password and get information from server
login(Usr,Pass) ->
	case {re:run(Usr,"^[A-Za-z0-9]{6,16}$") , re:run(Pass,"^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{6,16}$")} of
		{{match,_},{match,_}} ->
			io:format("Valid Combo\n"),
			ok;
		_ ->
			failed
	end.