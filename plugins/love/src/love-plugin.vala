// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.LovePlugin : Object, Plugin {
	private const string MIME_TYPE = "application/x-love-game";

	public string[] get_mime_types () {
		return { MIME_TYPE };
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (MIME_TYPE);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var package = new LovePackage (uri);
		var title = new LoveTitle (package);
		var icon = new LoveIcon (package);
		var cover = new LocalCover (uri);
		string[] args = { "love", uri.to_string () };
		var runner = new CommandRunner (args, true);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.LovePlugin);
}
