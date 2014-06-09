-module(info).

%% API.
-export([start/0]).

%% API.

start() ->
	application:start(crypto),
	application:start(public_key),
	application:start(ssl),
	application:start(hackney),
    ok = application:start(info).