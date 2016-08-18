// This file is part of GNOME Games. License: GPLv3

private class Games.PlayStation : Object, Plugin {
	private const string SEARCHED_MIME_TYPE = "application/x-cue";
	private const string SPECIFIC_MIME_TYPE = "application/x-playstation-rom";
	private const string MODULE_BASENAME = "libretro-playstation.so";
	private const bool SUPPORTS_SNAPSHOTTING = true;

	public GameSource get_game_source () throws Error {
		var game_uri_adapter = new GenericSyncGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		var query = new MimeTypeTrackerQuery (SEARCHED_MIME_TYPE, factory);
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
		var cover = new LocalCover (uri);
		var runner = new RetroRunner.with_mime_types (uri, uid, { SEARCHED_MIME_TYPE, SPECIFIC_MIME_TYPE }, MODULE_BASENAME, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.PlayStation);
}
