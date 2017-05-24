-module(player_serv).
-behaviour(gen_server).
-export([start_link/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2, send/3]).

-record(state, {socket=nil,key=nil,playerdata=nil,host=nil,mode=nil}).

start_link(Socket,Login) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {Socket,Login}, []).

init({Socket,Login}) ->
	io:format("--Player Init\n"),
	gen_server:cast(self(), accept),
	{ok, #state{socket=Socket,host=Login,mode=login}}.

%---------------------------------------------------------------------------------------------------
%Accept a client
handle_cast(accept, S = #state{host=Host,socket=ListenSocket}) ->
	{ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
	ok = inet:setopts(AcceptSocket, [{active, once}]),
	gen_server:cast(Host, new),
	{noreply, S#state{socket=AcceptSocket}};

%Handle any incoming info from the client
handle_cast({tcp, Socket, <<RequestID/integer,Data/binary>>}, S = #state{socket=Socket,host=Host,mode=Mode}) ->
	ListData = erlang:binary_to_list(Data),
	case player_response:read(ListData) of

		%Handle any connection specific functions
		{player,PlayerData} ->
			io:format("Handle it here\n"),
			player_response:respond(RequestID, PlayerData);

		%Forward on any other information
		{Mode,IncomingData} ->
			gen_server:cast(Host, {request, RequestID, self(), IncomingData});
		_ ->
			io:format("Unknown Request\n")
	end,
	
	%Prep to receive the next message
	ok = inet:setopts(Socket, [{active, once}]),
	{noreply, S};

%info intended to be forwarded to the client	
handle_cast({state_change, Host, Mode, Data}, State = #state{socket=Socket}) ->
	gen_server:cast(self(),Data),
	{noreply, State#state{host=Host,mode=Mode}};

%info intended to be forwarded to the client	
handle_cast({client_reply, RequestID, Data}, State = #state{socket=Socket}) ->
	io:format("Got Response\n"),
	send(Socket, RequestID, "Logged In"),
	{noreply, State}.

%---------------------------------------------------------------------------------------------------
%Handle the initial receipt of client data
handle_info({tcp, Socket, Data}, State) ->
	gen_server:cast(self(), {tcp, Socket, Data}),
	{noreply, State};

%Handle a lost client (Let the game know they left)
handle_info({tcp_closed, _Socket}, State) ->
	io:format("Connection Lost\n"),
	%ToDo: Notify Server that they left
	{stop, tcp_closed, State}.

%---------------------------------------------------------------------------------------------------
handle_call(_Msg, _From, State) ->
	{noreply, State}.

%---------------------------------------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

terminate(_Reason, _State) ->
	io:format("Terminate\n"),
	ok.

%---------------------------------------------------------------------------------------------------
send(Socket, RequestID, Payload) ->
	%ToDo: Encrypt it here, depending on whether a key has been set
	CypherText = erlang:list_to_binary(Payload),
	gen_tcp:send(Socket, RequestID ++ CypherText).