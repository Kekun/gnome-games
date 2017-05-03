// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.MimeTypeTrackerUriQuery : Object, TrackerUriQuery {
	private string mime_type;

	public MimeTypeTrackerUriQuery (string mime_type) {
		this.mime_type = mime_type;
	}

	public string get_query () {
		return @"SELECT DISTINCT nie:url(?urn) WHERE { ?urn nie:mimeType \"$mime_type\" . }";
	}
}
