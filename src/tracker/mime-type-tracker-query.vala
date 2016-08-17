// This file is part of GNOME Games. License: GPLv3

public class Games.MimeTypeTrackerQuery : Object, TrackerQuery {
	private const uint HANDLED_URIS_PER_CYCLE = 5;

	private string mime_type;
	private GameUriAdapter game_for_uri;
	private string[] uris;

	public MimeTypeTrackerQuery (string mime_type, GameUriAdapter game_for_uri) {
		this.mime_type = mime_type;
		this.game_for_uri = game_for_uri;
		this.uris = {};
	}

	public string get_query () {
		return @"SELECT DISTINCT nie:url(?urn) WHERE { ?urn nie:mimeType \"$mime_type\" . }";
	}

	public bool is_cursor_valid (Tracker.Sparql.Cursor cursor) {
		var uri = cursor.get_string (0);

		return is_uri_valid (uri);
	}

	public bool is_uri_valid (string uri) {
		File file = File.new_for_uri(uri);
		try {
			return file.query_exists ();
		} catch (Error e) {
			debug (e.message);
		}

		return false;
	}

	public void process_cursor (Tracker.Sparql.Cursor cursor) {
		var uri = cursor.get_string (0);
		uris += uri;
	}

	public async void foreach_game (GameCallback game_callback) {
		uint handled_uris = 0;
		foreach (var uri in uris) {
			var file = File.new_for_uri (uri);
			if (!file.query_exists ())
				continue;

			try {
				var game = yield game_for_uri.game_for_uri (uri);
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
