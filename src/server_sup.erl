-module(server_sup).
-behavior(supervisor).
-export([start_link/1,stop/0]).
-export([init/1]).

start_link(Port) ->
	supervisor:start_link({local, master_serv}, ?MODULE, [Port]).

stop() ->
	gen_tcp:close(8080),
	case whereis(master_serv) of
		P when is_pid(P) ->
			exit(P, kill);
		_ -> ok
	end.

init(Port) ->
	io:format("Init Server_Sup\n"),
	MaxRestart = 6,
	MaxTime = 3600,
	LoginSpec = {login,{login_serv, start_link, [self(),Port]}, permanent, 10500, supervisor, [login_serv]},
	{ok, {{one_for_one, MaxRestart, MaxTime}, [LoginSpec]}}.