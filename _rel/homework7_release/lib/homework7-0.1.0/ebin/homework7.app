{application, 'homework7', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['cache','cache_h','homework7_app','homework7_sup']},
	{registered, [homework7_sup]},
	{applications, [kernel,stdlib,cowboy,jsone,jsx]},
	{optional_applications, []},
	{mod, {homework7_app, []}},
	{env, []}
]}.