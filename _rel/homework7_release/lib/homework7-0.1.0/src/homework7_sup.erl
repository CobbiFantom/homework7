-module(homework7_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	ChildSpecs =
		[#{id => cache_server,
			start => {cache, start_link, []},
			shutdown => brutal_kill}],
	{ok, {{one_for_one, 5, 5}, ChildSpecs}}.