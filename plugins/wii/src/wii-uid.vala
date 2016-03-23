// This file is part of GNOME Games. License: GPLv3

private class Games.WiiUid: Object {
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
