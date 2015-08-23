// This file is part of GNOME Games. License: GPLv3

private abstract class Games.MimeTypeTrackerQuery : Object, TrackerQuery {
	public string get_query () {
		return @"SELECT DISTINCT nie:url(?urn) WHERE { ?urn nie:mimeType \"$(get_mime_type ())\" . }";
	}

	public abstract string get_mime_type ();

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) throws Error {
		var uri = cursor.get_string (0);

		return game_for_uri (uri);
	}

	public abstract Game game_for_uri (string uri) throws Error;
}
