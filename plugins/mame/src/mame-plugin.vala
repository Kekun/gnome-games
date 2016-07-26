// This file is part of GNOME Games. License: GPLv3

private class Games.MamePlugin : Object, Plugin {
	private const string MODULE_BASENAME = "libretro-mame.so";
	private const string MIME_TYPE = "application/zip";
	private const bool SUPPORTS_SNAPSHOTTING = false;

	public GameSource get_game_source () throws Error {
		var query = new MimeTypeTrackerQuery (MIME_TYPE, game_for_uri);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var supported_games = MameGameInfo.get_supported_games ();

		var file = File.new_for_uri (uri);
		var game_id = file.get_basename ();
		game_id = /\.zip$/.replace (game_id, game_id.length, 0, "");

		if (!supported_games.contains (game_id))
			throw new MameError.INVALID_GAME_ID (_("Invalid MAME game id '%s' for '%s'."), game_id, uri);

		var uid_string = @"mame-$game_id".down ();
		var uid = new GenericUid (uid_string);

		var info = supported_games[game_id];
		var title_string = info.name;
		title_string = title_string.split ("(")[0];
		title_string = title_string.strip ();
		var title = new GenericTitle (title_string);

		var icon = new DummyIcon ();
		var cover = new DummyCover ();
		var runner =  new RetroRunner (MODULE_BASENAME, uri, uid, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MamePlugin);
}
