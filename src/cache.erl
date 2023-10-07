-module(cache).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([insert/2]).
-export([lookup/1]).
%-export([lookup/2]).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-include_lib("stdlib/include/ms_transform.hrl").

-record(work_state, {cache}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

insert(Key, Value) ->
    gen_server:call(?MODULE, {insert, Key, Value}).

lookup(Key) ->
    gen_server:call(?MODULE, {lookup, Key}).

%lookup(Date_From, Date_To) ->
 %   gen_server:call(?MODULE, {lookup, Date_From, Date_To}).

init([]) ->
    ets:new(?MODULE, [public, named_table]),
    {ok, #work_state{cache=[]}}.

handle_call({insert, Key, Value}, _From, State = #work_state{}) ->
    UnixTime = calendar:datetime_to_gregorian_seconds(calendar:universal_time()),
    case ets:info(?MODULE) of
        undefined ->
            {reply, undefined, State};
        _ ->
            ets:insert(?MODULE, {Key, Value, UnixTime}),
            {reply, {insert, ok}, State}
    end;

handle_call({lookup,Key}, _From, State) ->
    case ets:info(?MODULE) of
        undefined ->
            {reply, undefined, State};
        _ ->
            case ets:lookup(?MODULE, Key) of
                [] ->
                    {reply, undefined, State};
                [{Key, Value, _}] ->
                    {reply, Value, State}
            end
    end.

handle_cast(_Request, State = #work_state{}) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.

terminate(_, _) ->
    {shutdown,ok}.

code_change(_OldVsn, State = #work_state{}, _Extra) ->
    {ok, State}.
