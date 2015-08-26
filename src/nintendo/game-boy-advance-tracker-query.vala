// This file is part of GNOME Games. License: GPLv3

private class Games.GameBoyAdvanceTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-gba-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new GameBoyAdvanceGame (uri);
	}
}
