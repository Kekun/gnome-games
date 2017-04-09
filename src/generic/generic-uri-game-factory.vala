// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericUriGameFactory : Object, UriGameFactory {
	public delegate bool UriTest (string uri);
	private const uint HANDLED_URIS_PER_CYCLE = 5;

	private GameUriAdapter game_uri_adapter;
	private UriTest? uri_validity_test;
	private string[] uris;

	public GenericUriGameFactory (GameUriAdapter game_uri_adapter, owned UriTest? uri_validity_test = null) {
		this.game_uri_adapter = game_uri_adapter;
		this.uri_validity_test = (owned) uri_validity_test;
		this.uris = {};
	}

	public bool is_uri_valid (string uri) {
		return uri_validity_test == null ? true : uri_validity_test (uri);
	}

	public void add_uri (string uri) {
		uris += uri;
	}

	public async void foreach_game (GameCallback game_callback) {
		uint handled_uris = 0;
		foreach (var uri in uris) {
			var file = File.new_for_uri (uri);
			if (!file.query_exists ())
				continue;

			try {
				Game game = yield game_uri_adapter.game_for_uri (uri);
				game_callback (game);
			}
			catch (Error e) {
				debug (e.message);

				continue;
			}

			handled_uris++;

			// Free the execution only once every HANDLED_URIS_PER_CYCLE
			// games to speed up the execution by avoiding too many context
			// switching.
			if (handled_uris >= HANDLED_URIS_PER_CYCLE) {
				handled_uris = 0;

				Idle.add (this.foreach_game.callback);
				yield;
			}
		}
	}
}
