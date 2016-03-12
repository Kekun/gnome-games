// This file is part of GNOME Games. License: GPLv3

private class Games.NeoGeoPocketTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-neo-geo-pocket-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new NeoGeoPocketGame (uri);
	}
}