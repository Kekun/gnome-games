// This file is part of GNOME Games. License: GPLv3

private class Games.AmigaTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-amiga-disk-format";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new AmigaGame (uri);
	}
}
