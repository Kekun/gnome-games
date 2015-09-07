// This file is part of GNOME Games. License: GPLv3

private class Games.Nintendo64TrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-n64-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new Nintendo64Game (uri);
	}
}
