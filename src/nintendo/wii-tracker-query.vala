// This file is part of GNOME Games. License: GPLv3

private class Games.WiiTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-wii-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new WiiGame (uri);
	}
}
