// This file is part of GNOME Games. License: GPLv3

private class Games.Nintendo64Plugin : Object, Plugin {
	public GameSource get_game_source () throws Error {
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (new Nintendo64TrackerQuery ());

		return source;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.Nintendo64Plugin);
}
