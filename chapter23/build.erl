#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname build
main([]) ->
	{ok, Conf} = file:consult("processquest-1.0.0.config"),
	{ok, Spec} = reltool:get_target_spec(Conf),
	reltool:eval_target_spec(Spec, code:root_dir(), "rel").


