// This file is part of GNOME Games. License: GPLv3

// Documentation: http://koti.kapsi.fi/~antime/sega/files/ST-040-R4-051795.pdf
// Documentation: http://www.gamefaqs.com/saturn/916393-sega-saturn/faqs/26021
private class Games.SegaSaturnHeader : Object {
	private const size_t[] HEADER_OFFSETS = { 0x00, 0x10 };

	private const size_t MAGIC_OFFSET = 0x0;
	private const string MAGIC_VALUE = "SEGA SEGASATURN";

	private const size_t PRODUCT_NUMBER_OFFSET = 0x20;
	private const size_t PRODUCT_NUMBER_SIZE = 0xa;

	private const size_t AREAS_OFFSET = 0x40;
	private const size_t AREAS_SIZE = 0xa;

	private File file;
	private size_t? header_offset;

	public SegaSaturnHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws SegaSaturnError {
		// Getting the header offset needs to look for the header, and hence
		// check the validity of the file.
		get_header_offset ();
	}

	public string get_product_number () throws SegaSaturnError {
		var product_number = get_string_at_offset (PRODUCT_NUMBER_OFFSET, PRODUCT_NUMBER_SIZE);

		return product_number.strip ();
	}

	public string get_areas () throws SegaSaturnError {
		var areas = get_string_at_offset (AREAS_OFFSET, AREAS_SIZE);

		return areas.strip ();
	}

	private size_t get_header_offset () throws SegaSaturnError {
		if (header_offset != null)
			return header_offset;

		foreach (var offset in HEADER_OFFSETS)
			if (lookup_header_offset (offset))
				header_offset = offset;

		if (header_offset == null)
			throw new SegaSaturnError.INVALID_HEADER ("The file doesn't have a Sega Saturn header.");

		return header_offset;
	}

	private bool lookup_header_offset (size_t offset) throws SegaSaturnError {
		var stream = get_stream ();
		try {
			stream.seek (offset + MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new SegaSaturnError.INVALID_SIZE (@"Invalid Sega Saturn header size: $(e.message)");
		}

		var buffer = new uint8[MAGIC_VALUE.length];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new SegaSaturnError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;

		return magic == MAGIC_VALUE;
	}

	private string get_string_at_offset (size_t offset, size_t size) throws SegaSaturnError {
		var header_offset = get_header_offset ();
		var stream = get_stream ();
		try {
			stream.seek (header_offset + offset, SeekType.SET);
		}
		catch (Error e) {
			throw new SegaSaturnError.INVALID_SIZE (@"Invalid Sega Saturn header size: $(e.message)");
		}

		var buffer = new uint8[size];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new SegaSaturnError.INVALID_HEADER ("The file doesn't have a Sega Saturn header.");
		}

		return (string) buffer;
	}

	private FileInputStream get_stream () throws SegaSaturnError {
		try {
			return file.read ();
		}
		catch (Error e) {
			throw new SegaSaturnError.CANT_READ_FILE (@"Couldn't read file: $(e.message)");
		}
	}
}

errordomain Games.SegaSaturnError {
	CANT_READ_FILE,
	INVALID_SIZE,
	INVALID_HEADER,
	INVALID_DATE,
	INVALID_DISK_INFO,
}
