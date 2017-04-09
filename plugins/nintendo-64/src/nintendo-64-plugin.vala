// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.Nintendo64Plugin : Object, Plugin {
	private const string FINGERPRINT_PREFIX = "nintendo-64";
	private const string MIME_TYPE = "application/x-n64-rom";
	private const string PLATFORM = "Nintendo64";

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
		var uid = new FingerprintUid (uri, FINGERPRINT_PREFIX);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (PLATFORM, { MIME_TYPE });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.Nintendo64Plugin);
}
