// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.WiiUid: Object, Uid {
	private WiiHeader header;
	private string uid;

	public WiiUid (WiiHeader header) {
		this.header = header;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var game_id = header.get_game_id ();
		uid = @"wii-$game_id".down ();

		return uid;
	}
}
