// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.MasterSystemPlugin : Object, Plugin {
	private const string MASTER_SYSTEM_PREFIX = "master-system";
	private const string MASTER_SYSTEM_MIME_TYPE = "application/x-sms-rom";
	private const string MASTER_SYSTEM_PLATFORM = "MasterSystem";

	private const string GAME_GEAR_PREFIX = "game-gear";
	private const string GAME_GEAR_MIME_TYPE = "application/x-gamegear-rom";
	private const string GAME_GEAR_PLATFORM = "GameGear";

	private const string SG_1000_PREFIX = "sg-1000";
	private const string SG_1000_MIME_TYPE = "application/x-sg1000-rom";
	private const string SG_1000_PLATFORM = "SG1000";

	public string[] get_mime_types () {
		return {
			MASTER_SYSTEM_MIME_TYPE,
			GAME_GEAR_MIME_TYPE,
			SG_1000_MIME_TYPE,
		};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericSyncGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (MASTER_SYSTEM_MIME_TYPE);
		factory.add_mime_type (GAME_GEAR_MIME_TYPE);

		var sg_1000_game_uri_adapter = new GenericSyncGameUriAdapter (sg_1000_game_for_uri);
		var sg_1000_factory = new GenericUriGameFactory (sg_1000_game_uri_adapter);
		sg_1000_factory.add_mime_type (SG_1000_MIME_TYPE);

		return { factory, sg_1000_factory };
	}

	private static Game game_for_uri (string uri) throws Error {
		var file = File.new_for_uri (uri);
		var header = new MasterSystemHeader (file);
		header.check_validity ();

		string prefix;
		string mime_type;
		string platform;
		if (header.is_master_system ()) {
			prefix = MASTER_SYSTEM_PREFIX;
			mime_type = MASTER_SYSTEM_MIME_TYPE;
			platform = MASTER_SYSTEM_PLATFORM;
		}
		else if (header.is_game_gear ()) {
			prefix = GAME_GEAR_PREFIX;
			mime_type = GAME_GEAR_MIME_TYPE;
			platform = GAME_GEAR_PLATFORM;
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
		var core_source = new RetroCoreSource (platform, { mime_type });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}

	private static Game sg_1000_game_for_uri (string uri) throws Error {
		var uid = new FingerprintUid (uri, SG_1000_PREFIX);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, SG_1000_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (SG_1000_PLATFORM, { SG_1000_MIME_TYPE });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MasterSystemPlugin);
}
