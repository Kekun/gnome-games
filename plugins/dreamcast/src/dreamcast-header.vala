// This file is part of GNOME Games. License: GPLv3

private class Games.DreamcastHeader : Object {
	private const size_t HEADER_SIZE = 0x100;

	private const size_t MAGIC_OFFSET = 0x0;
	private const string MAGIC_VALUE = "SEGA SEGAKATANA";

	private const size_t PRODUCT_NUMBER_OFFSET = 0x40;
	private const size_t PRODUCT_NUMBER_SIZE = 0xa;

	private const size_t AREAS_OFFSET = 0x30;
	private const size_t AREAS_SIZE = 0x8;

	private File file;
	private size_t? header_offset;

	public DreamcastHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws DreamcastError {
		// Getting the header offset needs to look for the header, and hence
		// check the validity of the file.
		get_header_offset ();
	}

	public string get_product_number () throws DreamcastError {
		var product_number = get_string_at_offset (PRODUCT_NUMBER_OFFSET, PRODUCT_NUMBER_SIZE);

		return product_number.strip ();
	}

	public string get_areas () throws DreamcastError {
		var areas = get_string_at_offset (AREAS_OFFSET, AREAS_SIZE);

		return areas.strip ();
	}

	private size_t get_header_offset () throws DreamcastError {
		if (header_offset != null)
			return header_offset;

		var path = file.get_path ();
		var header_offsets = Grep.get_offsets (path, MAGIC_VALUE);

		foreach (var offset in header_offsets)
			if (lookup_header_offset (offset))
				header_offset = offset;

		if (header_offset == null)
			throw new DreamcastError.INVALID_HEADER (_("The file doesn't have a Dreamcast header."));

		return header_offset;
	}

	private bool lookup_header_offset (size_t offset) throws DreamcastError {
		var stream = get_stream ();
		try {
			stream.seek (offset + MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_SIZE (_("Invalid Dreamcast header size: %s"), e.message);
		}

		// The header must start with $MAGIC_VALUE.
		var buffer = new uint8[MAGIC_VALUE.length];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;

		if (magic != MAGIC_VALUE)
			return false;

		try {
			stream.seek (offset + MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_SIZE (_("Invalid Dreamcast header size: %s"), e.message);
		}

		// The header must be $HEADER_SIZE ASCII characters long.
		buffer = new uint8[HEADER_SIZE];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_SIZE (e.message);
		}

		var header = (string) buffer;

		return (header.length == buffer.length) && header.is_ascii ();
	}

	private string get_string_at_offset (size_t offset, size_t size) throws DreamcastError {
		var header_offset = get_header_offset ();
		var stream = get_stream ();
		try {
			stream.seek (header_offset + offset, SeekType.SET);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_SIZE (_("Invalid Dreamcast header size: %s"), e.message);
		}

		var buffer = new uint8[size];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new DreamcastError.INVALID_HEADER (_("The file doesn't have a Dreamcast header."));
		}

		return (string) buffer;
	}

	private FileInputStream get_stream () throws DreamcastError {
		try {
			return file.read ();
		}
		catch (Error e) {
			throw new DreamcastError.CANT_READ_FILE (_("Couldn't read file: %s"), e.message);
		}
	}
}

errordomain Games.DreamcastError {
	CANT_READ_FILE,
	INVALID_SIZE,
	INVALID_HEADER,
	INVALID_DATE,
	INVALID_DISK_INFO,
}
