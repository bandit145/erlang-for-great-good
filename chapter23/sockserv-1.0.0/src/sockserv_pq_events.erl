%%% Converts events from a player's event manager into a
%%% cast sent to the sockserv socket gen_server.
-module(sockserv_pq_events).
-behaviour(gen_event).
-export([init/1, handle_event/2, handle_call/2, handle_info/2,
         terminate/2, code_change/3]).
-record(state, {queue=[], parent_pid, queuing=false}).

init(Parent) -> {ok, #state{parent_pid=Parent}}.



handle_event(resume, S = #state{parent_pid=Pid}) ->
	{ok, S#state{queuing=false}};
handle_event(E, S = #state{parent_pid=Pid, queue=Q ,queuing=true}) ->
	io:format("Current Queue status ~w~n",[Q]),
	io:format("adding another item to the Queue ~w~n",[E]),
    {ok, S#state{queue = [E|Q]}};
%% write handler to queue
handle_event(pause, S) ->
	{ok, S#state{queuing=true}};
%after queing is disabled wait for next event to come along and process out queue during that event
handle_event(E, S = #state{parent_pid=Pid, queue=Q}) when length(Q) > 0 ->
	io:format("DUMP EEEET!"),
    lists:foreach(fun(QE) -> gen_server:cast(Pid, QE) end, Q),
    gen_server:cast(Pid, E),
    {ok, S#state{queue=[]}};
handle_event(E, S = #state{parent_pid=Pid}) ->
    gen_server:cast(Pid, E),
    {ok, S}.

handle_call(Req, S = #state{parent_pid=Pid}) ->
    Pid ! Req,
    {ok, ok, S}.

handle_info(E, S = #state{parent_pid=Pid}) ->
    Pid ! E,
    {ok, S}.

terminate(_, _) -> ok.

code_change(_OldVsn, S = #state{parent_pid=Pid}, _Extra) ->
    {ok, S}.
