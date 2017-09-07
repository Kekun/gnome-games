// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PlayStationHeader : Object {
	// The ID prefixes must always be in uppercase.
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

		string label;
		string exe;
		if (!get_playstation_info (file.get_path (), out label, out exe))
			throw new PlayStationError.INVALID_HEADER (_("Not a PlayStation disc: “%s”."), file.get_uri ());

		_disc_id = parse_id_from_exe (exe);
		if (_disc_id != null)
			return;

		_disc_id = parse_id_from_label (label);
		if (_disc_id != null)
			return;

		throw new PlayStationError.INVALID_HEADER (_("Invalid PlayStation header: disc ID not found in “%s”."), file.get_uri ());
	}

	private string? parse_id_from_exe (string exe) throws Error {
		// Add 1 to either turn -1 into 0 or to skip the found character.
		var start = int.max (exe.last_index_of ("\\"), exe.last_index_of ("/")) + 1;
		var disc_id = exe.offset (start);
		disc_id = disc_id.strip ();
		disc_id = disc_id.split (";")[0];
		disc_id = disc_id.replace ("_", "-");
		disc_id = disc_id.replace (".", "");
		disc_id = disc_id.up ();

		if (!is_a_disc_id (disc_id))
			return null;

		return disc_id;
	}

	private string? parse_id_from_label (string label) throws Error {
		var disc_id = label.strip ();
		disc_id = disc_id.replace ("_", "-");
		disc_id = disc_id.strip ();
		disc_id = disc_id.up ();

		if (!is_a_disc_id (disc_id))
			return null;

		return disc_id;
	}

	private static bool is_a_disc_id (string disc_id) {
		if (disc_id_regex == null)
			disc_id_regex = /[A-Z]{4}-\d{5}/;

		return disc_id_regex.match (disc_id);
	}

	[CCode (cname = "get_playstation_info")]
	private static extern bool get_playstation_info (string filename, out string label, out string exe) throws Error;
}
