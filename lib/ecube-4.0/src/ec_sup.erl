%%%-------------------------------------------------------------------
%%% File    : ec_sup.erl
%%% Author  : Olivier <olivier@biniou.info>
%%% Description : Top-level supervisor
%%%-------------------------------------------------------------------
-module(ec_sup).
-author('olivier@biniou.info').
-vsn("3.0").

-include("ec.hrl").

-behaviour(supervisor).

%% Supervisor API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).


start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


init([]) ->
    CfgSrv = {ec_cf, {ec_cf, start_link, []},
	      permanent, brutal_kill, worker, [ec_cf]},

    VolSrv = {ec_vol, {ec_vol, start_link, []},
	      permanent, brutal_kill, worker, [ec_vol]},

    TexSrv = {ec_tex, {ec_tex, start_link, []},
	      permanent, ?TIMEOUT, worker, [ec_tex]},

    GUI = {ec_gui, {ec_gui, start_link, []},
	   permanent, ?TIMEOUT, worker, [ec_gui]},

    Demo = {ec_demo, {ec_demo, start_link, []},
	    permanent, ?TIMEOUT, worker, [ec_demo]},

    OSD = {ec_osd, {ec_osd, start_link, []},
	   permanent, ?TIMEOUT, worker, [ec_osd]},

    M3D = {ec_m3d, {ec_m3d, start_link, []},
	   permanent, brutal_kill, worker, [ec_m3d]},

    PCAP = {ec_pcap, {ec_pcap, start_link, []},
	    permanent, ?TIMEOUT, worker, [ec_pcap]},

    PT3D = {ec_pt3d, {ec_pt3d, start_link, []},
	    %% permanent, ?TIMEOUT, worker, [ec_pt3d]},
	    permanent, brutal_kill, worker, [ec_pt3d]},

    PS = {ec_ps, {ec_ps, start_link, []},
	  permanent, ?TIMEOUT, worker, [ec_ps]},
    %% permanent, brutal_kill, worker, [ec_pt3d]},

%%    {ok, {{one_for_one, 10, 1}, [CfgSrv, VolSrv, TexSrv, GUI, Demo, OSD, PCAP]}}.
    {ok, {{one_for_one, 10, 1}, [CfgSrv, VolSrv, TexSrv, GUI, PS, Demo, OSD, PT3D]}}.
%% {ok, {{one_for_one, 10, 1}, [CfgSrv, VolSrv, TexSrv, GUI, Demo, OSD, M3D]}}.
