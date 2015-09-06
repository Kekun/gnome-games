// This file is part of GNOME Games. License: GPLv3

private class Games.TrackerGameSource : Object, GameSource {
	private Tracker.Sparql.Connection connection { private set; get; }
	private GenericSet<TrackerQuery> queries;

	public TrackerGameSource (Tracker.Sparql.Connection connection) {
		this.connection = connection;
	}

	construct {
		queries = new GenericSet<TrackerQuery> (direct_hash, direct_equal);
	}

	public void add_query (TrackerQuery query) {
		queries.add (query);
	}

	public async void each_game (GameCallback game_callback) {
		queries.@foreach ((query) => {
			var sparql = query.get_query ();
			Tracker.Sparql.Cursor cursor;
			try {
				cursor = connection.query (sparql);
			}
			catch (Error e) {
				warning ("Error: %s\n", e.message);
				return;
			}

			bool is_cursor_valid = false;

			try {
				is_cursor_valid = cursor.next ();
			}
			catch (Error e) {
				is_cursor_valid = false;
				warning ("Error: %s\n", e.message);
			}
			while (is_cursor_valid) {
				try {
					var game = query.game_for_cursor (cursor);
					game_callback (game);
				}
				catch (TrackerError.GAME_IS_BLACKLISTED e) {
				}
				catch (Error e) {
					warning ("Error: %s\n", e.message);
				}

				try {
					is_cursor_valid = cursor.next ();
				}
				catch (Error e) {
					is_cursor_valid = false;
					warning ("Error: %s\n", e.message);
				}
			}
		});
	}
}

private errordomain TrackerError {
	GAME_IS_BLACKLISTED,
}
