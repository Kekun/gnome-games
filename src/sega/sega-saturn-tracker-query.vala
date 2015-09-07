// This file is part of GNOME Games. License: GPLv3

private class Games.SegaSaturnTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-saturn-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new SegaSaturnGame (uri);
	}
}
