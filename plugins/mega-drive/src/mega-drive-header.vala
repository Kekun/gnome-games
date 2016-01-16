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

			try {
				stream.seek (DOMESTIC_NAME_OFFSET, SeekType.SET);
			}
			catch (Error e) {
				_domestic_name = "";

				return _domestic_name;
			}

			var buffer = new uint8[NAME_SIZE];
			try {
				stream.read (buffer);
			}
			catch (Error e) {
				_domestic_name = "";

				return _domestic_name;
			}

			_domestic_name = (string) buffer;

			return _domestic_name;
		}
	}

	private FileInputStream stream;

	public MegaDriveHeader (File file) throws Error {
		stream = file.read ();

		check_validity ();
	}

	public void check_validity () throws MegaDriveError {
		try {
			stream.seek (MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new MegaDriveError.INVALID_SIZE (@"Invalid Mega Drive/Genesis/32X header size: $(e.message)");
		}

		var buffer = new uint8[MAGIC_SIZE];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new MegaDriveError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;
		magic = magic.chomp ();
		if (!(magic in MAGIC_VALUES))
			throw new MegaDriveError.INVALID_HEADER ("The file doesn't have a Mega Drive/Genesis/32X header.");
	}
}

errordomain Games.MegaDriveError {
	INVALID_SIZE,
	INVALID_HEADER,
}
