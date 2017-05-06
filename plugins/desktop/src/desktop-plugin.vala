// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DesktopPlugin : Object, Plugin {
	private const string MIME_TYPE = "application/x-desktop";

	public string[] get_mime_types () {
		return { MIME_TYPE };
	}

	public UriSource[] get_uri_sources () {
		var query = new DesktopTrackerUriQuery ();
		try {
			var connection = Tracker.Sparql.Connection.@get ();
			var uri_source = new TrackerUriSource (connection);
			uri_source.add_query (query);

			return { uri_source };
		}
		catch (Error e) {
			debug (e.message);

			return {};
		}
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (MIME_TYPE);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		check_uri (uri);

		var file = uri.to_file ();
		var path = file.get_path ();

		var app_info = new DesktopAppInfo.from_filename (path);
		var title = new DesktopTitle (app_info);
		var icon = new DesktopIcon (app_info);
		var cover = new DummyCover ();

		string[] args;
		var command = app_info.get_commandline ();
		if (!Shell.parse_argv (command, out args))
			throw new CommandError.INVALID_COMMAND (_("Invalid command “%s”."), command);
		var runner = new CommandRunner (args, true);

		return new GenericGame (title, icon, cover, runner);
	}

	private static void check_uri (Uri uri) throws Error {
		var file = uri.to_file ();

		if (!file.query_exists ())
			throw new IOError.NOT_FOUND (_("Tracker listed file not found: “%s”."), uri.to_string ());

		var path = file.get_path ();
		var app_info = new DesktopAppInfo.from_filename (path);

		if (app_info == null)
			throw new DesktopError.INVALID_APPINFO (_("Couldn’t parse desktop entry “%s”."), path);

		check_displayability (app_info);
		check_categories (app_info);
		check_executable (app_info);
		check_base_name (file);
	}

	private static void check_displayability (DesktopAppInfo app_info) throws Error {
		if (app_info.get_nodisplay ())
			throw new DesktopError.BLACKLISTED_GAME (_("“%s” shouldn’t be displayed."), app_info.filename);

		if (app_info.get_is_hidden ())
			throw new DesktopError.BLACKLISTED_GAME (_("“%s” is hidden."), app_info.filename);
	}

	private static void check_categories (DesktopAppInfo app_info) throws Error {
		var categories_string = app_info.get_categories ();
		var categories = categories_string.split (";");

		foreach (var category in get_categories_black_list ())
			if (category in categories)
				throw new DesktopError.BLACKLISTED_GAME (_("“%s” has blacklisted category “%s”."), app_info.filename, category);
	}

	private static void check_executable (DesktopAppInfo app_info) throws Error {
		var app_executable = app_info.get_executable ();

		foreach (var executable in get_executable_black_list ())
			if (app_executable == executable ||
			    app_executable.has_suffix ("/" + executable))
				throw new DesktopError.BLACKLISTED_GAME (_("“%s” has blacklisted executable “%s”."), app_info.filename, executable);
	}

	private static void check_base_name (File file) throws Error {
		var base_name = file.get_basename ();

		if (base_name in get_base_name_black_list ())
			throw new DesktopError.BLACKLISTED_GAME (_("“%s” is blacklisted."), file.get_path ());
	}

	private static string[] categories_black_list;
	private static string[] get_categories_black_list () throws Error {
		if (categories_black_list == null)
			categories_black_list = get_lines_from_resource ("plugins/desktop/blacklists/desktop-categories.blacklist");

		return categories_black_list;
	}

	private static string[] executable_black_list;
	private static string[] get_executable_black_list () throws Error {
		if (executable_black_list == null)
			executable_black_list = get_lines_from_resource ("plugins/desktop/blacklists/desktop-executable.blacklist");

		return executable_black_list;
	}

	private static string[] base_name_black_list;
	private static string[] get_base_name_black_list () throws Error {
		if (base_name_black_list == null)
			base_name_black_list = get_lines_from_resource ("plugins/desktop/blacklists/desktop-base-name.blacklist");

		return base_name_black_list;
	}

	private static string[] get_lines_from_resource (string resource) throws Error {
		var bytes = resources_lookup_data ("/org/gnome/Games/" + resource, ResourceLookupFlags.NONE);
		var text = (string) bytes.get_data ();

		string[] lines = {};

		foreach (var line in text.split ("\n"))
			if (line != "")
				lines += line;

		return lines;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.DesktopPlugin);
}
