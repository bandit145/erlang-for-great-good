-module(trade_fsm).
-behavior(gen_fsm).

%%public api
-export([start/1, start_link/1,trade/2,accept_trade/1,make_offer/2,retract_offer/2,ready/1,cancel/1]).

%%gen_fsm callbacks
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4,
	%custom state names
	idle/2, idle/3, idle_wait/2, idle_wait/3, negotiate/2,
	negotiate/3, wait/2, ready/2, ready/3]).

-record(state, {name="",
				other,
				ownitems=[],
				otheritems=[],
				monitor,
				from}).

%%%PUBLIC API

start(Name) ->
	gen_fsm:start(?MODULE, [Name], []).

start_link(Name) ->
	gen_fsm:start_link(?MODULE, [Name], []).

%% Ask for a begin sessions. Returns when/if the other accepts.
trade(OwnPid, OtherPid) ->
	gen_fsm:sync_send_event(OwnPid, {negotiate, OtherPid} 30000).

%%accept someones trade offer
accept_trade(OwnPid) ->
	gen_fsm:sync_send_event(OwnPid, accept_negotiate).

%% send an item on the table to be traded
make_offer(OwnPid, Item) ->
	gen_fsm:send_event(OwnPid, {make_offer, Item}).

%% cancel trade offer
retract_offer(OwnPid, Item) ->
	gen_fsm:send_event(OwnPid, {retract_offer, Item}).

%%mention that you are ready to trade. When the other
%% player also declares they're ready, the trade is done.
ready(OwnPid) ->
	gen_fsm:sync_send_event(OwnPid, ready, infinity).

%% cancel the transaction
cancel(OwnPid) ->
	gen_fsm:sync_send_all_state_event(OwnPid, cancel).

%%fsm to fsm functions

%ask negotiate
ask_negotiate(OtherPid, OwnPid) ->
	gen_fsm:send_event(OtherPid, {ask_negotiate, OwnPid}).

%%forward the client message accepting the transaction
accept_negotiate(OtherPid, OwnPid) ->
	gen_fsm:send_event(OtherPid, {accept_negotiate, OwnPid}).

%% forward a clients offer
do_offer(OtherPid, Item) ->
	gen_fsm:send_event(OtherPid, {do_offer, Item}).

%% forward a clients offer cancellation
undo_offer(OtherPid, Item) ->
	gen_fsm:send_event(OtherPid, {undo_offer, Item}).

%% ask the other side if they're ready to trade
are_you_ready(OtherPid) ->
	gen_fsm:send_event(OtherPid, are_you_ready).

%% Reply that the side is not ready to trade,
%% i.e. is not in 'wait' state.
not_yet(OtherPid) ->
	gen_fsm:send_event(OtherPid, not_yet).

%% Tells the other fsm that the user is currently waiting
%% for the ready state. State should transition to 'ready'.
am_ready(OtherPid) ->
	gen_fsm:send_event(OtherPid, 'ready!').

%%acknowledge that the fsm is in a ready state
ack_trans(OtherPid) ->
	gen_fsm:send_event(OtherPid, ack).

%% ask if ready to commit
ask_commit(OtherPid) ->
	gen_fsm:sync_send_event(OtherPid, ask_commit).

%% begin the synchronous commit.
do_commit(OtherPid) ->
	gen_fsm:sync_send_event(OtherPid, do_commit).

notify_cancel(OtherPid) ->
	gen_fsm:send_all_state_event(OtherPid, cancel).

%% gen fsm callbacks
init(Name) ->
	{ok, idle, #state{name=Name}}.