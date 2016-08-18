// This file is part of GNOME Games. License: GPLv3

private class Games.LovePlugin : Object, Plugin {
	private const string MIME_TYPE = "application/x-love-game";

	public GameSource get_game_source () throws Error {
		var game_uri_adapter = new GenericSyncGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		var query = new MimeTypeTrackerQuery (MIME_TYPE, factory);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var package = new LovePackage (uri);
		var title = new LoveTitle (package);
		var icon = new LoveIcon (package);
		var cover = new LocalCover (uri);
		string[] args = { "love", uri };
		var runner = new CommandRunner (args, true);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.LovePlugin);
}
