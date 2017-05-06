// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.TrackerUriIterator : Object, UriIterator {
	private Tracker.Sparql.Connection connection;
	private TrackerUriQuery[] queries;
	private int query_index;
	private Uri? uri;
	private Tracker.Sparql.Cursor cursor;

	internal TrackerUriIterator (Tracker.Sparql.Connection connection, TrackerUriQuery[] queries) {
		this.connection = connection;
		this.queries = queries;
		query_index = 0;
		uri = null;
		cursor = null;
	}

	public new Uri? get () {
		return uri;
	}

	public bool next () {
		while (query_index < queries.length) {
			if (try_next_for_query (queries[query_index]))
				return true;

			query_index++;
		}

		return false;
	}

	private bool try_next_for_query (TrackerUriQuery query) {
		try {
			if (next_for_query (query))
				return true;
		}
		catch (Error e) {
			debug (e.message);
		}

		uri = null;
		cursor = null;

		return false;
	}

	private bool next_for_query (TrackerUriQuery query) throws Error {
		if (cursor == null) {
			var sparql = query.get_query ();
			cursor = connection.query (sparql);
		}

		if (!cursor.next ())
			return false;

		uri = new Uri (cursor.get_string (0));

		return true;
	}
}
