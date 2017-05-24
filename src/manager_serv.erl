-module(manager_serv).
-behaviour(gen_server).
-export([start_link/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {players=nil}).

start_link(Sup,Login) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {Sup,Login}, []).

init({Sup,Login}) ->
	io:format("--Init Manager_Serv\n"),
	gen_server:cast(self(), {start_areas,Sup}),
	gen_server:cast(Login, {game_started, self()}),
	{ok, #state{}}.

%---------------------------------------------------------------------------------------------------
%Initial Setup
handle_cast({start_areas,Sup}, State) ->
	AreaSupSpec = {areas,{area_sup, start_link, [self()]}, permanent, 10500, supervisor, [area_sup]},
	{ok, Pid} = supervisor:start_child(Sup,AreaSupSpec),
	supervisor:start_child(Pid,[]), %ToDo: Start these based on config files
	{noreply, State#state{players=Pid}};

%Add area to list
handle_cast({area_started,Area}, State) ->
	{noreply, State};

%Handle requests
handle_cast({request, RequestID, Sender, Data}, State) ->
	io:format("Manager Response"),
	{noreply, State}.

%---------------------------------------------------------------------------------------------------

handle_info( _ , State) ->
	{noreply, State}.

%---------------------------------------------------------------------------------------------------
handle_call(_Msg, _From, State) ->
	{noreply, State}.

%---------------------------------------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.