-module(game_sup).
-behavior(supervisor).
-export([start_link/1,stop/0]).
-export([init/1]).

start_link(Login) ->
	supervisor:start_link({local, manager_super}, ?MODULE, Login).

stop() ->
	case whereis(manager_super) of
		P when is_pid(P) ->
			exit(P, kill);
		_ -> ok
	end.

init(Login) ->
	io:format("-Init Game_Sup\n"),
	MaxRestart = 6,
	MaxTime = 3600,
	ManagerSpec = {game_manager,{manager_serv, start_link, [self(),Login]}, permanent, 10500, supervisor, [manager_serv]},
	{ok, {{one_for_one, MaxRestart, MaxTime}, [ManagerSpec]}}.