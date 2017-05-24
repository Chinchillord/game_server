-module(area_serv).
-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {manager=nil,players=[]}).

start_link(Manager) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, Manager, []).

init(Manager) ->
	io:format("---Area Init\n"),
	gen_server:cast(self(), start),
	{ok, #state{manager=Manager}}.

handle_cast(start, S = #state{manager=Manager}) ->
	gen_server:cast(Manager, {area_started, self()}),
	{noreply, S};
handle_cast( _ , S ) ->
	{noreply, S}.

handle_info(_, State) ->
	{noreply, State}.

handle_call(_Msg, _From, State) ->
	{noreply, State}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

terminate(_Reason, _State) ->
	io:format("Terminate\n"),
	ok.