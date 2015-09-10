// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopTrackerQuery : Object, TrackerQuery {
	private static const string[] EXECUTABLE_BLACK_LIST = {
		"steam",
	};

	public string get_query () {
		return "SELECT ?soft WHERE { ?soft nie:isLogicalPartOf 'urn:software-category:Game' . }";
	}

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) throws Error {
		var uri = cursor.get_string (0);
		var file = File.new_for_uri (uri);

		var path = file.get_path ();
		var app_info = new DesktopAppInfo.from_filename (path);

		check_categories (app_info);
		check_executable (app_info);
		check_base_name (file);

		return new DesktopGame (uri);
	}

	private void check_categories (DesktopAppInfo app_info) throws Error {
		var categories_string = app_info.get_categories ();
		var categories = categories_string.split (";");

		foreach (var category in get_categories_black_list ())
			if (category in categories)
				throw new TrackerError.GAME_IS_BLACKLISTED (@"'$(app_info.filename)' has blacklisted category '$category'.");
	}

	private void check_executable (DesktopAppInfo app_info) throws Error {
		var app_executable = app_info.get_executable ();

		foreach (var executable in EXECUTABLE_BLACK_LIST)
			if (app_executable == executable ||
			    app_executable.has_suffix ("/" + executable))
				throw new TrackerError.GAME_IS_BLACKLISTED (@"'$(app_info.filename)' has blacklisted executable '$executable'.");
	}

	private void check_base_name (File file) throws Error {
		var base_name = file.get_basename ();

		if (base_name in get_base_name_black_list ())
			throw new TrackerError.GAME_IS_BLACKLISTED (@"'$(file.get_path ())' is blacklisted.");
	}

	private static string[] categories_black_list;
	private static string[] get_categories_black_list () {
		if (categories_black_list == null)
			categories_black_list = get_lines_from_resource ("blacklists/desktop-categories.blacklist");

		return categories_black_list;
	}

	private static string[] base_name_black_list;
	private static string[] get_base_name_black_list () {
		if (base_name_black_list == null)
			base_name_black_list = get_lines_from_resource ("blacklists/desktop-base-name.blacklist");

		return base_name_black_list;
	}

	private static string[] get_lines_from_resource (string resource) {
		var bytes = resources_lookup_data ("/org/gnome/Games/" + resource, ResourceLookupFlags.NONE);
		var text = (string) bytes.get_data ();

		string[] lines = {};

		foreach (var line in text.split ("\n"))
			if (line != "")
				lines += line;

		return lines;
	}
}
