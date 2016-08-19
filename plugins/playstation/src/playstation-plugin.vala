// This file is part of GNOME Games. License: GPLv3

private class Games.PlayStation : Object, Plugin {
	private const string SEARCHED_MIME_TYPE = "application/x-cue";

	public GameSource get_game_source () throws Error {
		var factory = new PlayStationGameFactory ();
		var query = new MimeTypeTrackerQuery (SEARCHED_MIME_TYPE, factory);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.PlayStation);
}
