// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.TrackerUriSource : Object, UriSource {
	private Tracker.Sparql.Connection connection { private set; get; }
	private TrackerUriQuery[] queries;

	public TrackerUriSource (Tracker.Sparql.Connection connection) {
		this.connection = connection;
	}

	construct {
		queries = {};
	}

	public void add_query (TrackerUriQuery query) {
		queries += query;
	}

	public UriIterator iterator () {
		return new TrackerUriIterator (connection, queries);
	}
}
