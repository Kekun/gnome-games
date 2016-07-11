// This file is part of GNOME Games. License: GPLv3

public class Games.TrackerGameSource : Object, GameSource {
	private const uint HANDLED_CURSORS_PER_CYCLE = 5;

	private Tracker.Sparql.Connection connection { private set; get; }
	private TrackerQuery[] queries;

	public TrackerGameSource (Tracker.Sparql.Connection connection) {
		this.connection = connection;
	}

	construct {
		queries = {};
	}

	public void add_query (TrackerQuery query) {
		queries += query;
	}

	public async void each_game (GameCallback game_callback) {
		for (size_t i = 0 ; i < queries.length ; i++)
			yield each_game_for_query (game_callback, queries[i]);
	}

	public async void each_game_for_query (GameCallback game_callback, TrackerQuery query) {
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
		uint handled_cursors = 0;

		try {
			is_cursor_valid = cursor.next ();
		}
		catch (Error e) {
			is_cursor_valid = false;
			warning ("Error: %s\n", e.message);
		}
		while (is_cursor_valid) {
			if (query.is_cursor_valid (cursor)) {
				query.process_cursor (cursor);
				handled_cursors++;

				// Free the execution only once every HANDLED_CURSORS_PER_CYCLE
				// games to speed up the execution by avoiding too many context
				// switching.
				if (handled_cursors >= HANDLED_CURSORS_PER_CYCLE) {
					handled_cursors = 0;

					Idle.add (this.each_game_for_query.callback);
					yield;
				}
			}

			try {
				is_cursor_valid = cursor.next ();
			}
			catch (Error e) {
				is_cursor_valid = false;
				warning ("Error: %s\n", e.message);
				continue;
			}
		}
		yield query.foreach_game (game_callback);
	}
}

public errordomain TrackerError {
	FILE_NOT_FOUND,
}
