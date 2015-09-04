// This file is part of GNOME Games. License: GPLv3

private class Games.SteamGameSource : Object, GameSource {
	// From the home directory.
	private const string REGISTRY_PATH = "/.steam/registry.vdf";
	// From the default install directory.
	private const string LIBRARY_DIRS_PATH = "/SteamApps/libraryfolders.vdf";

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
		var library_reg_path = install_path + LIBRARY_DIRS_PATH;
		var library_reg = new SteamRegistry (library_reg_path);
		foreach (var child in library_reg.get_children ({ "LibraryFolders" }))
			if (/^\d+$/.match (child))
				libraries += library_reg.get_data ({ "LibraryFolders", child });
	}

	public void each_game (GameCallback game_callback) {
		foreach (var library in libraries) {
			each_game_in_steamapps_dir (library + "/SteamApps", game_callback);
			each_game_in_steamapps_dir (library + "/steamapps", game_callback);
		}
	}

	public void each_game_in_steamapps_dir (string directory, GameCallback game_callback) {
		try {
			var file = File.new_for_path (directory);

			var enumerator = file.enumerate_children (FileAttribute.STANDARD_NAME, 0);

			FileInfo info;
			while ((info = enumerator.next_file ()) != null)
				game_for_file_info (directory, info, game_callback);
		}
		catch (Error e) {
		}
	}

	public void game_for_file_info (string directory, FileInfo info, GameCallback game_callback) {
		var name = info.get_name ();
		if (appmanifest_regex.match (name)) {
			try {
				var game = new SteamGame (@"$directory/$name");
				game_callback (game);
			}
			catch (Error e) {
				warning ("%s\n", e.message);
			}
		}
	}
}
