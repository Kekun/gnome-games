// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericUriGameFactory : Object, UriGameFactory {
	private const uint GAMES_PER_CYCLE = 4;

	private GameUriAdapter game_uri_adapter;
	private HashTable<Uri, Game> game_for_uri;
	private string[] mime_types;
	private string[] schemes;

	public GenericUriGameFactory (GameUriAdapter game_uri_adapter) {
		this.game_uri_adapter = game_uri_adapter;
		game_for_uri = new HashTable<Uri, Game> (Uri.hash, Uri.equal);
		mime_types = {};
		schemes = {};
	}

	public string[] get_mime_types () {
		return mime_types;
	}

	public void add_mime_type (string mime_type) {
		mime_types += mime_type;
	}

	public string[] get_schemes () {
		return schemes;
	}

	public void add_scheme (string scheme) {
		schemes += scheme;
	}

	public async void add_uri (Uri uri) {
		Idle.add (this.add_uri.callback);
		yield;

		if (game_for_uri.contains (uri))
			return;

		try {
			var game = yield game_uri_adapter.game_for_uri (uri);
			game_for_uri[uri] = game;

			game_added (game);
		}
		catch (Error e) {
			debug (e.message);
		}
	}

	public async Game? query_game_for_uri (Uri uri) {
		Idle.add (this.query_game_for_uri.callback);
		yield;

		if (game_for_uri.contains (uri))
			return game_for_uri[uri];

		return null;
	}

	public async void foreach_game (GameCallback game_callback) {
		uint handled_uris = 0;
		var games = game_for_uri.get_values ();
		for (unowned List<Game> game = games; game != null; game = game.next) {
			game_callback (game.data);

			if (handled_uris++ < GAMES_PER_CYCLE)
				continue;

			// Free the execution only once every HANDLED_URIS_PER_CYCLE
			// games to speed up the execution by avoiding too many context
			// switching.
			handled_uris = 0;

			Idle.add (this.foreach_game.callback);
			yield;
		}
	}
}
