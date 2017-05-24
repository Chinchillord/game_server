-module(login_serv).
-behaviour(gen_server).
-export([start_link/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {player_serv=nil,player_count=1, player_limit=100, game=nil}).

%---------------------------------------------------------------------------------------------------
start_link(Serv,Port) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {Serv,Port}, []).

init({Sup,Port}) ->
	io:format("-Init Login_Serv\n"),
	gen_server:cast(self(), {setup,Sup,Port}),
	{ok, #state{}}.

%---------------------------------------------------------------------------------------------------
%Initial Setup
handle_cast({setup,Sup,Port}, State) ->
	%Start Player Supervisor
	PlayerSupSpec = {players,{player_sup, start_link, [Port,self()]}, permanent, 10500, supervisor, [player_sup]},
	{ok, PlayerPid} = supervisor:start_child(Sup,PlayerSupSpec),
	supervisor:start_child(PlayerPid,[]),

	%Start Game Server
	GameSupSpec = {game_overlord,{game_sup, start_link, [self()]}, permanent, 10500, supervisor, [game_sup]},
	{ok, GamePid} = supervisor:start_child(Sup,GameSupSpec),
	supervisor:start_child(GamePid,[]),

	{noreply, State#state{player_serv=PlayerPid,game=GamePid}};

%Game manager started
handle_cast({game_started,Manager}, State) ->
	{noreply, State};

%Start a new client connection (unless the limit has been reached)
handle_cast(new, S = #state{player_serv=PlayerPid,player_count=PlayerCount,player_limit=PlayerLimit}) ->
	io:format("Player Connected\n"),
	supervisor:start_child(PlayerPid,[]),
	{noreply, S#state{player_count=PlayerCount + 1}};

%Request from the player waiting on a response
handle_cast({request,RequestID,Sender,Data}, State) ->
	NewState = login_response:respond(Sender, RequestID, Data, State),
	{noreply, NewState}.

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