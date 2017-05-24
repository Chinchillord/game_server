{application, living_world_server,
	[{vsn, "1.0.0"},
	{modules, [living_world_server, server_sup, player_sup, player_serv,player_response,login_response, manager_serv, manager_response, area_sup, area_serv]},
	{registered, [living_world_server]},
	{mod, {living_world_server, []}}
	]}.