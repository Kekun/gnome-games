// This file is part of GNOME Games. License: GPLv3

private class Games.PlayStationHeader : Object {
	private const size_t[] OFFSETS = { 0xD368, 0xD3A8 };
	private const string[] IDS = { "SLUS", "SCUS", "SLES", "SCES", "SLPS", "SLPM", "SCPS" };
	private const string MAGIC_VALUE = "BOOT";

	private string _disc_id;
	public string disc_id {
		get { return _disc_id; }
	}

	private File file;

	public PlayStationHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		var stream = new StringInputStream (file);
		var offset = get_header_offset ();
		var header = stream.read_string (offset);

		foreach (var id in IDS) {
			if (!(id in header))
				continue;

			var raw_id = header.split (id)[1];
			raw_id = raw_id.split (";")[0];
			raw_id = raw_id.replace ("_", "-");
			raw_id = raw_id.replace (".", "");
			_disc_id = raw_id;
		}

		if (_disc_id == null)
			throw new PlayStationError.INVALID_HEADER (_("Invalid PlayStation header: disc ID not found in '%s'."), file.get_uri ());
	}

	private size_t get_header_offset () throws Error {
		var stream = new StringInputStream (file);

		foreach (var offset in OFFSETS)
			if (stream.has_string (offset, MAGIC_VALUE))
				return offset;

		throw new PlayStationError.INVALID_HEADER (_("PlayStation header not found in '%s'."), file.get_uri ());
	}
}
