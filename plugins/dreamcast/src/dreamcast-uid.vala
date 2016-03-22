// This file is part of GNOME Games. License: GPLv3

private class Games.DreamcastUid: Object, Uid {
	private DreamcastHeader header;
	private string uid;

	public DreamcastUid (DreamcastHeader header) {
		this.header = header;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var product_number = header.get_product_number ();
		var areas = header.get_areas ();
		uid = @"dreamcast-$product_number-$areas".down ();

		return uid;
	}
}
