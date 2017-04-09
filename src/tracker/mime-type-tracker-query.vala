// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.MimeTypeTrackerQuery : Object, TrackerQuery {
	private string mime_type;
	private UriGameFactory uri_game_factory;

	public MimeTypeTrackerQuery (string mime_type, UriGameFactory uri_game_factory) {
		this.mime_type = mime_type;
		this.uri_game_factory = uri_game_factory;
	}

	public string get_query () {
		return @"SELECT DISTINCT nie:url(?urn) WHERE { ?urn nie:mimeType \"$mime_type\" . }";
	}

	public bool is_cursor_valid (Tracker.Sparql.Cursor cursor) {
		var uri = cursor.get_string (0);

		return uri_game_factory.is_uri_valid (uri);
	}

	public void process_cursor (Tracker.Sparql.Cursor cursor) {
		var uri = cursor.get_string (0);
		uri_game_factory.add_uri (uri);
	}

	public async void foreach_game (GameCallback game_callback) {
		yield uri_game_factory.foreach_game (game_callback);
	}
}
