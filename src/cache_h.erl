-module(cache_h).

%% API
-export([init/2, answer/2]).


init(Req0, _Opts) ->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    method_check(Method, HasBody, Req0).

method_check(<<"POST">>, true, Req0) ->
    {ok, Body, _Req} = cowboy_req:read_urlencoded_body(Req0),
    [{Body2, true}] = Body,
    Json = jsone:decode(Body2),
    Action = maps:get(<<"action">>, Json),
    Data = {Action, Json},
    action(Data, Req0);

method_check(_, _, Req0) ->
    cowboy_req:reply(200, #{
        << "content-type" >>  =>  << "text/plain" >>
    }, <<"Wrong method \n">>, Req0).

answer(Value, Req0) ->
    cowboy_req:reply(200, #{
        << "content-type" >>  =>  << "text/plain" >>
    }, jsone:encode(#{<<"result" >> => Value}), Req0).

action({<<"insert">>, Json}, Req0) ->
    Key = map_get(<<"key">>, Json),
    Value = map_get(<<"value">>, Json),
    {insert, ok} = cache:insert(Key, Value),
    answer(<<"ok">>, Req0);

action({<<"lookup">>, Json}, Req0) ->
    Key = map_get(<<"key">>, Json),
    Value = cache:lookup(Key),
    answer(Value, Req0);

action({<<"lookup_by_date">>, _Json}, Req0) ->
 %  Date_From = map_get(<<"date_from">>, Json),
 %  Date_To = map_get(<<"date_to">>, Json),
    Value = <<"No_finished">>,
    answer(Value, Req0).
 %   cowboy_req:reply(200, #{
 %       << "content-type" >>  =>  << "text/plain" >>
 %   }, jsone:encode(#{Date_From => Date_To}), Req0).




%============================================================
%cowboy
%============================================================

% curl -H "Content-Type: application/json" -X POST -d '{"action":"insert","key":"some_key", "value":[1,2,3]}' http://localhost:8080/api/cache_server

%============================================================