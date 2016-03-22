// This file is part of GNOME Games. License: GPLv3

public class Games.MimeTypeTrackerQuery : Object, TrackerQuery {
	public delegate Game GameForUri (string uri) throws Error;

	private string mime_type;
	private GameForUri game_for_uri;

	public MimeTypeTrackerQuery (string mime_type, GameForUri game_for_uri) {
		this.mime_type = mime_type;
		this.game_for_uri = game_for_uri;
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
			var info =  file.query_info ("*", FileQueryInfoFlags.NONE);

			return info.get_content_type () == mime_type;
		} catch (Error e) {
			debug (e.message);
		}

		return false;
	}

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) throws Error {
		var uri = cursor.get_string (0);

		var file = File.new_for_uri (uri);
		if (!file.query_exists ())
			throw new TrackerError.FILE_NOT_FOUND ("Tracker listed file not found: '%s'.", uri);

		return game_for_uri (uri);
	}
}
