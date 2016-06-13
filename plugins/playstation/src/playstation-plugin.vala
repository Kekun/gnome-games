// This file is part of GNOME Games. License: GPLv3

private class Games.PlayStation : Object, Plugin {
	private const string MIME_TYPE = "application/x-cue";
	private const string MODULE_BASENAME = "libretro-playstation.so";
	private const bool SUPPORTS_SNAPSHOTTING = true;

	public GameSource get_game_source () throws Error {
		var query = new MimeTypeTrackerQuery (MIME_TYPE, game_for_uri);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var cue_file = File.new_for_uri (uri);
		var cue_sheet = new CueSheet (cue_file);
		var cue_track_node = cue_sheet.get_track (0);
		var bin_file = cue_track_node.file.file;
		var header = new PlayStationHeader (bin_file);
		header.check_validity ();

		var uid = new PlayStationUid (header);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var cover = new DummyCover ();
		var runner = new RetroRunner (MODULE_BASENAME, uri, uid, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.PlayStation);
}
