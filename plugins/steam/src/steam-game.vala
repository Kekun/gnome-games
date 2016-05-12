// This file is part of GNOME Games. License: GPLv3

private class Games.SteamGame : Object, Game {
	private string _name;
	public string name {
		get { return _name; }
	}

	private string game_id;

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
	}

	public Icon get_icon () {
		return new SteamIcon (game_id);
	}

	public Runner get_runner () throws Error {
		string[] args = { "steam", @"steam://rungameid/$game_id" };

		return new CommandRunner (args, false);
	}
}

errordomain Games.SteamGameError {
	NO_APPID,
	NO_NAME,
}
