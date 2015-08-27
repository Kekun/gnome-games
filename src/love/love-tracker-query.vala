// This file is part of GNOME Games. License: GPLv3

private class Games.LoveTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-love-game";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new LoveGame (uri);
	}
}
