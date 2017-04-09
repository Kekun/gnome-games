// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PlayStationUid: Object, Uid {
	private PlayStationHeader header;
	private string uid;

	public PlayStationUid (PlayStationHeader header) {
		this.header = header;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var disc_id = header.disc_id;
		uid = @"playstation-$disc_id".down ();

		return uid;
	}
}
