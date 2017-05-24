-module(player_sup).
-export([start_link/2, init/1]).
-behaviour(supervisor).

start_link([Port],Login) ->
	supervisor:start_link(?MODULE, {Port,Login}).

init({Port,Login}) ->
	io:format("-Init Player_Sup\n"),
	case gen_tcp:listen(Port, [{active, false}, binary, {packet,2}]) of
		{ok, Socket} ->
			MaxRestart = 1,
			MaxTime = 3600,
			{ok, {{simple_one_for_one, MaxRestart, MaxTime},
				[{serv,
					{player_serv, start_link, [Socket,Login]},
					temporary,
					5000,
					worker,
					[player_serv]}]}};
		{error, Error} -> 
			{error, Error}
	end.