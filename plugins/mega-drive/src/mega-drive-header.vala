// This file is part of GNOME Games. License: GPLv3

// Documentation: https://en.wikibooks.org/wiki/Genesis_Programming
private class Games.MegaDriveHeader : Object {
	private const size_t MAGIC_OFFSET = 0x100;
	private const size_t MAGIC_SIZE = 0xf;
	private const string[] MAGIC_VALUES = {
		"SEGA MEGA DRIVE",
		"SEGA GENESIS",
		"SEGA 32X",
	};

	private const size_t DOMESTIC_NAME_OFFSET = 0x120;
	private const size_t NAME_SIZE = 0x30;

	private string _domestic_name;
	public string domestic_name {
		get {
			if (_domestic_name != null)
				return _domestic_name;

			var stream = new StringInputStream (file);
			try {
				_domestic_name = stream.read_string_for_size (DOMESTIC_NAME_OFFSET, NAME_SIZE);
			}
			catch (Error e) {
				_domestic_name = "";
			}

			return _domestic_name;
		}
	}

	private File file;

	public MegaDriveHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		var stream = new StringInputStream (file);
		var magic = stream.read_string_for_size (MAGIC_OFFSET, MAGIC_SIZE);
		magic = magic.chomp ();
		if (!(magic in MAGIC_VALUES))
			throw new MegaDriveError.INVALID_HEADER (_("The file doesn't have a Genesis/Sega 32X/Sega CD/Sega Pico header."));
	}
}

errordomain Games.MegaDriveError {
	INVALID_HEADER,
}
