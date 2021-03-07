-module(m8ball).
-behavior(application).
-export([start/2, stop/1]).
-export([ask/1]).

%% callbacks
start(normal, []) ->
	m8ball_sup:start_link();
start({takeover, _OtherNode}, []) ->
	m8ball_sup:start_link().

stop(_State) ->
	ok.

%%interface

ask(Question) ->
	m8ball_server:ask(Question).