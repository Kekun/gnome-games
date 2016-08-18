// This file is part of GNOME Games. License: GPLv3

private class Games.MegaDrivePlugin : Object, Plugin {
	private const string MEGA_DRIVE_PREFIX = "mega-drive";
	private const string MEGA_DRIVE_MIME_TYPE = "application/x-genesis-rom";

	private const string 32X_PREFIX = "mega-drive-32x";
	private const string 32X_MIME_TYPE = "application/x-genesis-32x-rom";

	private const string PICO_PREFIX = "sega-pico";
	private const string PICO_MIME_TYPE = "application/x-sega-pico-rom";

	private const string MEGA_CD_PREFIX = "mega-cd";
	private const string CUE_MIME_TYPE = "application/x-cue";
	private const string MEGA_CD_MIME_TYPE = "application/x-sega-cd-rom";

	private const string MODULE_BASENAME = "libretro-mega-drive.so";
	private const bool SUPPORTS_SNAPSHOTTING = true;

	public GameSource get_game_source () throws Error {
		var game_uri_adapter = new GenericSyncGameUriAdapter (game_for_uri);
		var cd_game_uri_adapter = new GenericSyncGameUriAdapter (cd_game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		var mega_cd_factory = new GenericUriGameFactory (cd_game_uri_adapter);
		var mega_drive_query = new MimeTypeTrackerQuery (MEGA_DRIVE_MIME_TYPE, factory);
		var 32x_query = new MimeTypeTrackerQuery (32X_MIME_TYPE, factory);
		var mega_cd_query = new MimeTypeTrackerQuery (CUE_MIME_TYPE, mega_cd_factory);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (mega_drive_query);
		source.add_query (32x_query);
		source.add_query (mega_cd_query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var file = File.new_for_uri (uri);
		var header = new MegaDriveHeader (file);
		header.check_validity ();

		string prefix;
		string mime_type;
		if (header.is_mega_drive ()) {
			prefix = MEGA_DRIVE_PREFIX;
			mime_type = MEGA_DRIVE_MIME_TYPE;
		}
		else if (header.is_32x ()) {
			prefix = 32X_PREFIX;
			mime_type = 32X_MIME_TYPE;
		}
		else if (header.is_pico ()) {
			prefix = PICO_PREFIX;
			mime_type = PICO_MIME_TYPE;
		}
		else
			assert_not_reached ();

		var uid = new FingerprintUid (uri, prefix);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, mime_type);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var runner = new RetroRunner.with_mime_types (uri, uid, { mime_type }, MODULE_BASENAME, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}

	private static Game cd_game_for_uri (string uri) throws Error {
		var file = File.new_for_uri (uri);
		var cue = new CueSheet (file);
		var bin_file = get_binary_file (cue);

		var header = new MegaDriveHeader (bin_file);
		header.check_validity ();

		string[] mime_types;
		if (header.is_mega_drive ())
			mime_types = { CUE_MIME_TYPE, MEGA_CD_MIME_TYPE };
		else if (header.is_32x ())
			mime_types = { CUE_MIME_TYPE, MEGA_CD_MIME_TYPE, 32X_MIME_TYPE };
		else
			assert_not_reached ();

		var bin_uri = bin_file.get_uri ();
		var header_offset = header.get_offset ();
		var uid = new FingerprintUid.for_chunk (bin_uri, MEGA_CD_PREFIX, header_offset, MegaDriveHeader.HEADER_LENGTH);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MEGA_CD_MIME_TYPE);
		var cover = new GriloCover (media, uid);
		var runner = new RetroRunner.with_mime_types (uri, uid, mime_types, MODULE_BASENAME, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}

	private static File get_binary_file (CueSheet cue) throws Error {
		if (cue.tracks_number == 0)
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a track."), cue.file.get_uri ());

		var track = cue.get_track (0);
		var file = track.file;

		if (file.file_format != CueSheetFileFormat.BINARY && file.file_format != CueSheetFileFormat.UNKNOWN)
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a valid binary file format."), cue.file.get_uri ());

		if (!track.track_mode.is_mode1 ())
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file '%s' doesn't have a valid track mode for track %d."), cue.file.get_uri (), track.track_number);

		var header = new MegaDriveHeader (file.file);
		header.check_validity ();

		return file.file;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MegaDrivePlugin);
}
