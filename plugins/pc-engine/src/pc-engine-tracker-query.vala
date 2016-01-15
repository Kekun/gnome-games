// This file is part of GNOME Games. License: GPLv3

private class Games.PcEngineTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/x-pc-engine-rom";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new PcEngineGame (uri);
	}
}
