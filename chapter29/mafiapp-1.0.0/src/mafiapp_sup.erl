-module(mafiapp_sup).
-behavior(supervisor).
-export([start_link/1]).
-export([init/1]).

start_link(Tables) ->
	supervisor:start_link(?MODULE, Tables).

%%this does absolutley nothing, only there to
%% allow waiting for tables
init(Tables) ->
	{ok, {{one_for_one, 1, 1}, []}}.