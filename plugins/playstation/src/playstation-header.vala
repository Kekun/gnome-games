// This file is part of GNOME Games. License: GPLv3

private class Games.PlayStationHeader : Object {
	private const size_t[] BOOT_OFFSETS = {
		0xD368, // .bin
		0xD3A8, // .iso
	};
	private const string BOOT_MAGIC_VALUE = "BOOT";

	private const string[] IDS = { "SLUS", "SCUS", "SLES", "SCES", "SLPS", "SLPM", "SCPS" };

	private string _disc_id;
	public string disc_id {
		get { return _disc_id; }
	}

	private File file;

	public PlayStationHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		if (_disc_id != null)
			return;

		_disc_id = get_id_from_boot ();
		if (_disc_id != null)
			return;

		throw new PlayStationError.INVALID_HEADER (_("Invalid PlayStation header: disc ID not found in '%s'."), file.get_uri ());
	}

	private string? get_id_from_boot () throws Error {
		var offset = get_boot_offset ();
		if (offset == null)
			return null;

		var stream = new StringInputStream (file);
		var header = stream.read_string (offset);

		foreach (var id in IDS) {
			if (!(id in header))
				continue;

			var raw_id = header.split (id)[1];
			raw_id = raw_id.split (";")[0];
			raw_id = raw_id.replace ("_", "-");
			raw_id = raw_id.replace (".", "");
			raw_id = (id + raw_id).up ();

			return raw_id;
		}

		return null;
	}

	private size_t? get_boot_offset () throws Error {
		var stream = new StringInputStream (file);

		foreach (var offset in BOOT_OFFSETS)
			if (stream.has_string (offset, BOOT_MAGIC_VALUE))
				return offset;

		return null;
	}
}
