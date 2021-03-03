%%% Converts events from a player's event manager into a
%%% cast sent to the sockserv socket gen_server.
-module(sockserv_pq_events).
-behaviour(gen_event).
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3]).
-record(state, {queue, parent_pid, queuing=false}).

init(Parent) -> 

	{ok, #state{parent_pid=Parent, queue=queue:new()}}.

handle_event(E, S = #state{parent_pid=Pid}) ->
    gen_server:cast(Pid, E),
    {ok, S};
%% write handler to queue
handle_event(resume, S) ->
	{ok, S = #state{queuing=false}}.

handle_event(queue, S) ->
	{ok, S = #state{queuing=true}}.

handle_call(Req, S = #state{parent_pid=Pid}) ->
    Pid ! Req,
    {ok, ok, S}.

handle_info(E, S = #state{parent_pid=Pid}) ->
    Pid ! E,
    {ok, S}.

terminate(_, _) -> ok.

code_change(_OldVsn, S = #state{parent_pid=Pid}, _Extra) ->
    {ok, S}.
