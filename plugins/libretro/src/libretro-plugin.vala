// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.LibretroPlugin : Object, Plugin {
	private const string LIBRETRO_FILE_SCHEME = "libretro+file";

	public UriSource[] get_uri_sources () {
		var source = new LibretroUriSource ();

		return { source };
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_scheme (LIBRETRO_FILE_SCHEME);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file_uri = new Uri.from_uri_and_scheme (uri, "file");
		var file = file_uri.to_file ();
		if (!file.query_exists ())
			throw new LibretroError.NOT_A_LIBRETRO_DESCRIPTOR ("This isn’t a Libretro core descriptor: %s", uri.to_string ());

		var path = file.get_path ();
		var core_descriptor = new Retro.CoreDescriptor (path);
		if (!core_descriptor.get_is_game ())
			throw new LibretroError.NOT_A_GAME ("This Libretro core descriptor doesn't isn’t a game: %s", uri.to_string ());

		var uid = new LibretroUid (core_descriptor);
		var title = new LibretroTitle (core_descriptor);
		var icon = new LibretroIcon (core_descriptor);
		var cover = new DummyCover ();
		var runner = new RetroRunner.for_core_descriptor (core_descriptor, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.LibretroPlugin);
}
