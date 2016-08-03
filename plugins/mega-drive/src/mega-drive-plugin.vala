// This file is part of GNOME Games. License: GPLv3

private class Games.MegaDrivePlugin : Object, Plugin {
	private const string MEGA_DRIVE_PREFIX = "mega-drive";
	private const string MEGA_DRIVE_MIME_TYPE = "application/x-genesis-rom";

	private const string 32X_PREFIX = "mega-drive-32x";
	private const string 32X_MIME_TYPE = "application/x-genesis-32x-rom";

	private const string PICO_PREFIX = "sega-pico";
	private const string PICO_MIME_TYPE = "application/x-sega-pico-rom";

	private const string MODULE_BASENAME = "libretro-mega-drive.so";
	private const bool SUPPORTS_SNAPSHOTTING = true;

	public GameSource get_game_source () throws Error {
		var mega_drive_query = new MimeTypeTrackerQuery (MEGA_DRIVE_MIME_TYPE, game_for_uri);
		var 32x_query = new MimeTypeTrackerQuery (32X_MIME_TYPE, game_for_uri);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (mega_drive_query);
		source.add_query (32x_query);

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
		var cover = new GriloCover (media, uid);
		var runner =  new RetroRunner (MODULE_BASENAME, uri, uid, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MegaDrivePlugin);
}
