// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PlayStationUid: Object, Uid {
	private string disc_set_id;
	private string uid;

	public PlayStationUid (string disc_set_id) {
		this.disc_set_id = disc_set_id;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		uid = @"playstation-$disc_set_id".down ();

		return uid;
	}
}
