// This file is part of GNOME Games. License: GPLv3

private class Games.DreamcastTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-dc-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new DreamcastGame (uri);
	}
}
