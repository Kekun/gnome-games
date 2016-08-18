// This file is part of GNOME Games. License: GPLv3

private class Games.SegaSaturnPlugin : Object, Plugin {
	private const string SEARCHED_MIME_TYPE = "application/x-cue";
	private const string SPECIFIC_MIME_TYPE = "application/x-saturn-rom";
	private const string MODULE_BASENAME = "libretro-saturn.so";
	private const bool SUPPORTS_SNAPSHOTTING = false;

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
		var file = File.new_for_uri (uri);
		var cue = new CueSheet (file);
		var bin_file = get_binary_file (cue);

		var header = new SegaSaturnHeader (bin_file);
		header.check_validity ();

		var uid = new SegaSaturnUid (header);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, SPECIFIC_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var runner = new RetroRunner.with_mime_types (uri, uid, { SEARCHED_MIME_TYPE, SPECIFIC_MIME_TYPE }, MODULE_BASENAME, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}

	private static File get_binary_file (CueSheet cue) throws Error {
		if (cue.tracks_number == 0)
			throw new SegaSaturnError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a track."), cue.file.get_uri ());

		var track = cue.get_track (0);
		var file = track.file;

		if (file.file_format != CueSheetFileFormat.BINARY && file.file_format != CueSheetFileFormat.UNKNOWN)
			throw new SegaSaturnError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a valid binary file format."), cue.file.get_uri ());

		if (!track.track_mode.is_mode1 ())
			throw new SegaSaturnError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a valid track mode for track %d."), cue.file.get_uri (), track.track_number);

		var file_info = file.file.query_info ("*", FileQueryInfoFlags.NONE);
		if (file_info.get_content_type () != SPECIFIC_MIME_TYPE)
			throw new SegaSaturnError.INVALID_FILE_TYPE (_("The file '%s' doesn't have a valid Sega Saturn binary file."), cue.file.get_uri ());

		return file.file;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.SegaSaturnPlugin);
}
