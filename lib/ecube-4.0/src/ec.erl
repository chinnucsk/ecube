-module(ec).
-author('olivier@biniou.info').
-vsn("1.0").

-include("ec.hrl").

-export([start/0, stop/0]).
-export([vsn/0, priv_path/1, get_env/1]).


start() ->
    application:start(?APPNAME).


stop() ->
    application:stop(?APPNAME).


vsn() ->
    {ok, Vsn} = application:get_key(?APPNAME, vsn),
    Vsn.


priv_path(File) ->
    PrivDir = code:priv_dir(?APPNAME),
    [PrivDir, "/", File].


get_env(Key) ->
    case application:get_env(?APPNAME, Key) of
	{ok, Val} ->
	    Val;
	undefined ->
	    undefined
    end.
