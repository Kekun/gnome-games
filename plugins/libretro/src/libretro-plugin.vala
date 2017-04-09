// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.LibretroPlugin : Object, Plugin {
	public GameSource get_game_source () throws Error {
		return new LibretroGameSource ();
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.LibretroPlugin);
}
