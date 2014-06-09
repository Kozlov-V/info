-module(info_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	io:format("Start request"),
	hackney:start(),
	P = spawn(info_stream, get_info, [self(), <<"7477474">>]),
	receive
		{Msg, P} ->
	 		io:format(Msg),
	 		exit(P, kill) 
	after 
	 	5000 ->
	 		io:format("Error request"),
	 		exit(P, kill) 
	end,

    info_sup:start_link().

stop(_State) ->
    ok.
