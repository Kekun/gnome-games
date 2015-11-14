// This file is part of GNOME Games. License: GPLv3

public abstract class Games.MimeTypeTrackerQuery : Object, TrackerQuery {
	public string get_query () {
		return @"SELECT DISTINCT nie:url(?urn) WHERE { ?urn nie:mimeType \"$(get_mime_type ())\" . }";
	}

	public abstract string get_mime_type ();

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) throws Error {
		var uri = cursor.get_string (0);

		var file = File.new_for_uri (uri);
		if (!file.query_exists ())
			throw new TrackerError.FILE_NOT_FOUND ("Tracker listed file not found: '%s'.", uri);

		return game_for_uri (uri);
	}

	public abstract Game game_for_uri (string uri) throws Error;
}
