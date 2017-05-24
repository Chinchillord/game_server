-module(area_sup).
-export([start_link/1, init/1]).
-behaviour(supervisor).

start_link(Manager) ->
	supervisor:start_link(?MODULE, Manager).

init(Manager) ->
	io:format("--Init Area_Sup\n"),
	MaxRestart = 10,
	MaxTime = 3600,
	{ok, {{simple_one_for_one, MaxRestart, MaxTime},
		[{areas,
			{area_serv, start_link, [Manager]},
			temporary,
			5000,
			worker,
			[area_serv]}]}}.