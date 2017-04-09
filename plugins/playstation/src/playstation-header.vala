// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PlayStationHeader : Object {
	private const size_t[] HEADER_OFFSETS = {
		0x85D2, // .bin.ecm
		0x9320, // .bin
		0x9360, // .iso 
	};
	private const size_t HEADER_TITLE_OFFSET = 0x20;
	private const string HEADER_MAGIC_VALUE = "PLAYSTATION";

	private const size_t[] BOOT_OFFSETS = {
		0xBE64, // .bin.ecm
		0xD368, // .bin
		0xD3A8, // .iso
		0xA9F98, // .bin
	};
	private const string BOOT_MAGIC_VALUE = "BOOT";

	// The ID prefixes must always be in uppercase.
	private const string[] IDS = { "SLUS", "SCUS", "SLES", "SCES", "SLPS", "SLPM", "SCPS" };
	private const size_t DISC_ID_SIZE = 10;

	private static Regex disc_id_regex;

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

		_disc_id = search_id_in_header ();
		if (_disc_id != null)
			return;

		throw new PlayStationError.INVALID_HEADER (_("Invalid PlayStation header: disc ID not found in “%s”."), file.get_uri ());
	}

	private string? search_id_in_header () throws Error {
		var offset = get_header_offset ();
		if (offset == null)
			return null;

		var stream = new StringInputStream (file);
		var header = stream.read_string_for_size (offset + HEADER_TITLE_OFFSET, DISC_ID_SIZE);

		var raw_id = header.up ();
		raw_id = raw_id.replace ("_", "-");

		foreach (var id in IDS) {
			if (!(id in header))
				continue;

			if (is_a_disc_id (raw_id))
				return raw_id;
		}

		return null;
	}

	private size_t? get_header_offset () throws Error {
		var stream = new StringInputStream (file);

		foreach (var offset in HEADER_OFFSETS)
			if (stream.has_string (offset, HEADER_MAGIC_VALUE))
				return offset;

		return null;
	}

	private string? get_id_from_boot () throws Error {
		var offset = get_boot_offset ();
		if (offset == null)
			return null;

		var stream = new StringInputStream (file);
		var header = stream.read_string (offset);
		header = header.up ();

		foreach (var id in IDS) {
			if (!(id in header))
				continue;

			var raw_id = header.split (id)[1];
			raw_id = raw_id.split (";")[0];
			raw_id = raw_id.replace ("_", "-");
			raw_id = raw_id.replace (".", "");
			raw_id = (id + raw_id).up ();

			if (is_a_disc_id (raw_id))
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

	private static bool is_a_disc_id (string disc_id) {
		if (disc_id_regex == null)
			disc_id_regex = /[A-Z]{4}-\d{5}/;

		return disc_id_regex.match (disc_id);
	}
}
