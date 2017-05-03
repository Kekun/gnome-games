// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamUriSource : Object, UriSource {
	// From the home directory.
	private const string REGISTRY_PATH = "/.steam/registry.vdf";
	// From the home directory.
	private const string DEFAULT_INSTALL_DIR_SYMLINK = "/.steam/steam";
	// From an install directory.
	private const string[] STEAMAPPS_DIRS = { "/SteamApps", "/steamapps" };
	// From the default SteamApp directory.
	private const string LIBRARY_DIRS_REG = "/libraryfolders.vdf";

	private const string[] INSTALL_PATH_REGISTRY_PATH =
		{ "Registry", "HKLM", "Software", "Valve", "Steam", "InstallPath" };

	private string[] directories;

	public SteamUriSource () throws Error {
		directories = {};

		// Steam's installation path can be found in its registry.
		var home = Environment.get_home_dir ();
		var registry_path = home + REGISTRY_PATH;
		var registry = new SteamRegistry (registry_path);
		var install_path = registry.get_data (INSTALL_PATH_REGISTRY_PATH);

		add_library (home + DEFAULT_INSTALL_DIR_SYMLINK);
		add_library (install_path);

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
					add_library (library_reg.get_data ({ "LibraryFolders", child }));
		}
	}

	public UriIterator iterator () {
		return new SteamUriIterator (directories);
	}

	private void add_library (string library) {
		foreach (var steamapps_dir in STEAMAPPS_DIRS) {
			var library_steamapps_dir = library + steamapps_dir;
			if (FileUtils.test (library_steamapps_dir, FileTest.EXISTS))
				directories += library_steamapps_dir;
		}
	}
}
