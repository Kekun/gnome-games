// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.MamePlugin : Object, Plugin {
	private const string MIME_TYPE = "application/zip";

	public string[] get_mime_types () {
		return { MIME_TYPE };
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new MameGameUriAdapter ();
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (MIME_TYPE);

		return { factory };
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MamePlugin);
}
