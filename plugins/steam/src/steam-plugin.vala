// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamPlugin : Object, Plugin {
	private const string STEAM_FILE_SCHEME = "steam+file";

	private static HashTable<string, Game> game_for_id;

	static construct {
		game_for_id = new HashTable<string, Game> (str_hash, str_equal);
	}

	public UriSource[] get_uri_sources () {
		try {
			var source = new SteamUriSource ();

			return { source };
		}
		catch (Error e) {
			debug (e.message);
		}

		return {};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_scheme (STEAM_FILE_SCHEME);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file_uri = new Uri.from_uri_and_scheme (uri, "file");
		var file = file_uri.to_file ();
		var appmanifest_path = file.get_path ();
		var registry = new SteamRegistry (appmanifest_path);
		var game_id = registry.get_data ({"AppState", "appid"});
		/* The gamegames_id sometimes is identified by appID
		 * see issue https://github.com/Kekun/gnome-games/issues/169 */
		if (game_id == null)
			game_id = registry.get_data ({"AppState", "appID"});

		if (game_id == null)
			throw new SteamError.NO_APPID (_("Couldn’t get Steam appid from manifest “%s”."), appmanifest_path);

		if (game_id in game_for_id) {
			var game = game_for_id[game_id];

			return game;
		}

		var title = new SteamTitle (registry);
		var icon = new SteamIcon (game_id);
		var cover = new SteamCover (game_id);
		string[] args = { "steam", @"steam://rungameid/" + game_id };
		var runner = new CommandRunner (args, false);

		var game = new GenericGame (title, icon, cover, runner);
		game_for_id[game_id] = game;

		return game;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.SteamPlugin);
}
