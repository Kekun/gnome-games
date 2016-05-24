// This file is part of GNOME Games. License: GPLv3

private class Games.SteamGameSource : Object, GameSource {
	// From the home directory.
	private const string REGISTRY_PATH = "/.steam/registry.vdf";
	// From an install directory.
	private const string[] STEAMAPPS_DIRS = { "/SteamApps", "/steamapps" };
	// From the default SteamApp directory.
	private const string LIBRARY_DIRS_REG = "/libraryfolders.vdf";

	private const string[] INSTALL_PATH_REGISTRY_PATH =
		{ "Registry", "HKLM", "Software", "Valve", "Steam", "InstallPath" };

	private static Regex appmanifest_regex;

	private string[] libraries;

	public SteamGameSource () throws Error {
		if (appmanifest_regex == null)
			appmanifest_regex = /appmanifest_\d+\.acf/;

		// Steam's installation path can be found in its registry.
		var registry_path = Environment.get_home_dir () + REGISTRY_PATH;
		var registry = new SteamRegistry (registry_path);
		var install_path = registry.get_data (INSTALL_PATH_REGISTRY_PATH);

		libraries = { install_path };

		// `/LibraryFolders/$NUMBER` entries in the libraryfolders.vdf registry
		// file are library directories.
		foreach (var steamapps_dir in STEAMAPPS_DIRS) {
			var install_steamapps_dir = install_path + steamapps_dir;
			var file = File.new_for_path (install_steamapps_dir);
			if (!file.query_exists ())
				continue;

			var library_reg_path = install_steamapps_dir + LIBRARY_DIRS_REG;
			var library_reg = new SteamRegistry (library_reg_path);
			foreach (var child in library_reg.get_children ({ "LibraryFolders" }))
				if (/^\d+$/.match (child))
					libraries += library_reg.get_data ({ "LibraryFolders", child });
		}
	}

	public async void each_game (GameCallback game_callback) {
		foreach (var library in libraries)
			foreach (var steamapps_dir in STEAMAPPS_DIRS)
				yield each_game_in_steamapps_dir (library + steamapps_dir, game_callback);
	}

	public async void each_game_in_steamapps_dir (string directory, GameCallback game_callback) {
		try {
			var file = File.new_for_path (directory);

			var enumerator = yield file.enumerate_children_async (FileAttribute.STANDARD_NAME, 0);

			FileInfo info;
			while ((info = enumerator.next_file ()) != null)
				yield game_for_file_info (directory, info, game_callback);
		}
		catch (Error e) {
		}
	}

	public async void game_for_file_info (string directory, FileInfo info, GameCallback game_callback) {
		var name = info.get_name ();
		if (appmanifest_regex.match (name)) {
			try {
				var game = game_for_appmanifest_path (@"$directory/$name");
				game_callback (game);

				Idle.add (this.game_for_file_info.callback);
				yield;
			}
			catch (Error e) {
				warning ("%s\n", e.message);
			}
		}
	}

	private static Game game_for_appmanifest_path (string appmanifest_path) throws Error {
		var registry = new SteamRegistry (appmanifest_path);
		var game_id = registry.get_data ({"AppState", "appid"});
		/* The game_id sometimes is identified by appID
		 * see issue https://github.com/Kekun/gnome-games/issues/169 */
		if (game_id == null)
			game_id = registry.get_data ({"AppState", "appID"});

		if (game_id == null)
			throw new SteamError.NO_APPID (@"Couldn't get Steam appid from manifest '$appmanifest_path'");

		var title = new SteamTitle (registry);
		var icon = new SteamIcon (game_id);
		var cover = new SteamCover (game_id);
		string[] args = { "steam", @"steam://rungameid/" + game_id };
		var runner = new CommandRunner (args, false);

		return new GenericGame (title, icon, cover, runner);
	}
}
