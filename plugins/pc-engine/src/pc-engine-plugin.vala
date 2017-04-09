// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PcEnginePlugin : Object, Plugin {
	private const string FINGERPRINT_PREFIX = "pc-engine";

	private const string MIME_TYPE = "application/x-pc-engine-rom";
	private const string PLATFORM = "TurboGrafx16";

	private const string CUE_MIME_TYPE = "application/x-cue";
	private const string CD_MAGIC_VALUE = "PC Engine CD-ROM SYSTEM";
	private const string CD_PLATFORM = "TurboGrafxCD";

	public GameSource get_game_source () throws Error {
		var game_uri_adapter = new GenericSyncGameUriAdapter (game_for_uri);
		var cd_game_uri_adapter = new GenericSyncGameUriAdapter (cd_game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		var cd_factory = new GenericUriGameFactory (cd_game_uri_adapter);
		var query = new MimeTypeTrackerQuery (MIME_TYPE, factory);
		var cd_query = new MimeTypeTrackerQuery (CUE_MIME_TYPE, cd_factory);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);
		source.add_query (cd_query);

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

	private static Game cd_game_for_uri (string uri) throws Error {
		if (!is_valid_disc (uri))
			throw new PcEngineError.INVALID_DISC ("“%s” isn’t a valid PC-Engine CD-ROM² disc.", uri);

		var uid = new FingerprintUid (uri, FINGERPRINT_PREFIX);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (CD_PLATFORM, { CUE_MIME_TYPE, MIME_TYPE });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}

	private static bool is_valid_disc (string uri) throws Error {
		var cue_file = File.new_for_uri (uri);
		var cue_sheet = new CueSheet (cue_file);
		if (cue_sheet.tracks_number < 2)
			return false;

		var track = cue_sheet.get_track (1);
		if (!track.track_mode.is_mode1 ())
			return false;

		var bin_file = track.file.file;
		var path = bin_file.get_path ();
		var offsets = Grep.get_offsets (path, CD_MAGIC_VALUE);

		return offsets.length > 0;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.PcEnginePlugin);
}
