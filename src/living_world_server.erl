-module(living_world_server).
-behaviour(application).
-export([start/2,stop/1]).

start(normal, _) ->
	io:format("\nLaunching Application\n"),
	server_sup:start_link(8080).

stop(_State) ->
	io:format("Closing Application\n\n"),
	ok.