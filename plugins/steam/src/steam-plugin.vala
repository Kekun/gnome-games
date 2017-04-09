// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamPlugin : Object, Plugin {
	public GameSource get_game_source () throws Error {
		return new SteamGameSource ();
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.SteamPlugin);
}
