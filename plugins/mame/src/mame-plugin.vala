// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.MamePlugin : Object, Plugin {
	private const string SEARCHED_MIME_TYPE = "application/zip";

	public GameSource get_game_source () throws Error {
		var game_uri_adapter = new MameGameUriAdapter ();
		var factory = new GenericUriGameFactory (game_uri_adapter);
		var query = new MimeTypeTrackerQuery (SEARCHED_MIME_TYPE, factory);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MamePlugin);
}
