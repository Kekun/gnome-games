// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: http://wiibrew.org/wiki/Wii_Disc
private class Games.WiiHeader: Object {
	private const size_t MAGIC_OFFSET = 0x18;
	private const string MAGIC_VALUE = "\x5d\x1c\x9e\xa3";

	private File file;

	public WiiHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws WiiError {
		var stream = get_stream ();
		try {
			stream.seek (MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new WiiError.INVALID_SIZE (_("Invalid Wii header size: %s"), e.message);
		}

		var buffer = new uint8[MAGIC_VALUE.length];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new WiiError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;
		if (magic != MAGIC_VALUE)
			throw new WiiError.INVALID_HEADER (_("The file doesn’t have a Wii header."));
	}

	public string get_game_id () throws WiiError {
		uint8 buffer[6];

		var stream = get_stream ();
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new WiiError.INVALID_HEADER (_("The file doesn’t have a Wii header."));
		}

		return (string) buffer;
	}

	private FileInputStream get_stream () throws WiiError {
		try {
			return file.read ();
		}
		catch (Error e) {
			throw new WiiError.CANT_READ_FILE (_("Couldn’t read file: %s"), e.message);
		}
	}
}

errordomain Games.WiiError {
	CANT_READ_FILE,
	INVALID_SIZE,
	INVALID_HEADER,
}
