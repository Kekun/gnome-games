// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.WonderSwanPlugin : Object, Plugin {
	private const string WONDERSWAN_PREFIX = "wonderswan";
	private const string WONDERSWAN_MIME_TYPE = "application/x-wonderswan-rom";
	private const string WONDERSWAN_PLATFORM = "WonderSwan";

	private const string WONDERSWAN_COLOR_PREFIX = "wonderswan-color";
	private const string WONDERSWAN_COLOR_MIME_TYPE = "application/x-wonderswan-color-rom";
	private const string WONDERSWAN_COLOR_PLATFORM = "WonderSwanColor";

	public string[] get_mime_types () {
		return {
			WONDERSWAN_MIME_TYPE,
			WONDERSWAN_COLOR_MIME_TYPE,
		};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (WONDERSWAN_MIME_TYPE);
		factory.add_mime_type (WONDERSWAN_COLOR_MIME_TYPE);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file = uri.to_file ();
		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();

		string prefix;
		string platform;
		switch (mime_type) {
		case WONDERSWAN_MIME_TYPE:
			prefix = WONDERSWAN_PREFIX;
			platform = WONDERSWAN_PLATFORM;

			break;
		case WONDERSWAN_COLOR_MIME_TYPE:
			prefix = WONDERSWAN_COLOR_PREFIX;
			platform = WONDERSWAN_COLOR_PLATFORM;

			break;
		default:
			assert_not_reached ();

			break;
		}

		var uid = new FingerprintUid (uri, prefix);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, mime_type);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (platform, { mime_type });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.WonderSwanPlugin);
}
