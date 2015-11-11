// This file is part of GNOME Games. License: GPLv3

private class Games.SteamGame : Object, Game {
	private static Icon? steam_icon;

	private string _name;
	public string name {
		get { return _name; }
	}

	private Icon? _icon;
	public Icon? icon {
		get { return _icon != null ? _icon : steam_icon; }
	}

	private string game_id;

	static construct {
		try {
			steam_icon = Icon.new_for_string ("steam");
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

	public SteamGame (string appmanifest_path) throws Error {
		var registry = new SteamRegistry (appmanifest_path);
		game_id = registry.get_data ({"AppState", "appid"});
		/* The game_id sometimes is identified by appID
		 * see issue https://github.com/Kekun/gnome-games/issues/169 */
		if (game_id == null)
			game_id = registry.get_data ({"AppState", "appID"});
		_name = registry.get_data ({"AppState", "name"});

		if (game_id == null)
			throw new SteamGameError.NO_APPID (@"Couldn't get Steam appid from manifest '$appmanifest_path'");

		if (name == null)
			throw new SteamGameError.NO_NAME (@"Couldn't get name from manifest '$appmanifest_path'");

		try {
			var icon_name = "steam_icon_" + game_id;
			if (check_icon_exists (icon_name))
				_icon = Icon.new_for_string (icon_name);
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

	public Runner get_runner () throws Error {
		return new SteamRunner (game_id);
	}

	private bool check_icon_exists (string icon_name) {
		var theme = Gtk.IconTheme.get_default ();

		return theme.has_icon (icon_name);
	}
}

errordomain Games.SteamGameError {
	NO_APPID,
	NO_NAME,
}
