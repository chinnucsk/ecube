%%%-------------------------------------------------------------------
%%% File    : rec.erl
%%% Author  : Olivier Girondel <olivier@biniou.info>
%%% Description : PulseAudio-based recorder
%%%-------------------------------------------------------------------
-module(rec).
-author('olivier@biniou.info').
-vsn("1.0").

-include("ec.hrl").

%% API
-export([start/0, record/1, stop/0]).

%% Internal exports
-export([init/0]).

-define(SPAN, 6).


start() -> 
    Pid = spawn_link(?MODULE, init, []),
    ?D_REGISTER(?MODULE, Pid).


record(Freq) -> 
    ?D_F("Recording at ~pHz", [Freq]),
    call_port({record, Freq}).


stop() ->
    call_port(stop),
    ?MODULE ! stop,
    ok.


call_port(Msg) ->
    Ref = make_ref(),
    ?MODULE ! {call, self(), Ref, Msg},
    receive
	{Ref, Result} ->
	    Result
    end.


init() ->
    %% ?D_YOUPI,
    process_flag(trap_exit, true),
    Port = open_port(),
    %% ?D_F("yaaeeahahahhahah port= ~p", [Port]),
    %% call_port({start, Freq}),
    loop(Port).


loop(Port) ->
    receive
	{Port, {data, BinData}} ->
	    Data = binary_to_term(BinData),
	    %% ?D_F("Got list of size ~p", [length(Data)]),
	    %%?D_F("Got list ~p", [Data]),
	    Points = pt3d(Data),
	    Curve = case curve:curve(?SPAN, Points) of
			{error, badarg} ->
			    [];
			C ->
			    C
		    end,
	    ec_pt3d:points(Curve),
	    loop(Port);

	{call, Caller, Ref, Msg} ->
	    Bin = term_to_binary(Msg),
	    %% ?D_F("Calling port with:~n~p (~p bytes) to Read~n", [Msg, byte_size(Bin)]),
	    port_command(Port, Bin),
	    receive
		{Port, {data, Data}} ->
		    Caller ! {Ref, binary_to_term(Data)},
		    loop(Port);
		
		_ ->
		    NewPort = open_port(),
		    Caller ! {Ref, {error, badarg}},
		    loop(NewPort)
	    end;

	stop ->
	    %%?D_F("stopping port ~p", [?MODULE]),
	    erlang:port_close(Port);
	
	_Other ->
	    ?D_UNHANDLED(_Other),
	    loop(Port)
    end.


open_port() ->
    open_port({spawn, "./rec"}, [{packet, 4}, binary]).


pt3d(List) ->
    pt3d(List, []).
pt3d([X,Y,Z|Tail], Acc) ->
    Point = {X, Y, Z},
    pt3d([Y,Z|Tail], [Point|Acc]);
pt3d(_Rest, Acc) -> %% no need to reverse, these are points
    Acc.
