// This file is part of GNOME Games. License: GPL-3.0+.

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

	public void check_validity () throws Error {
		// Getting the header offset needs to look for the header, and hence
		// check the validity of the file.
		get_header_offset ();
	}

	public string get_product_number () throws Error {
		var stream = new StringInputStream (file);
		var product_number = stream.read_string_for_size (PRODUCT_NUMBER_OFFSET, PRODUCT_NUMBER_SIZE);

		return product_number.strip ();
	}

	public string get_areas () throws Error {
		var stream = new StringInputStream (file);
		var areas = stream.read_string_for_size (AREAS_OFFSET, AREAS_SIZE);

		return areas.strip ();
	}

	private size_t get_header_offset () throws Error {
		if (header_offset != null)
			return header_offset;

		var path = file.get_path ();
		var header_offsets = Grep.get_offsets (path, MAGIC_VALUE);

		foreach (var offset in header_offsets)
			if (lookup_header_offset (offset))
				header_offset = offset;

		if (header_offset == null)
			throw new DreamcastError.INVALID_HEADER (_("The file doesn’t have a Dreamcast header."));

		return header_offset;
	}

	private bool lookup_header_offset (size_t offset) throws Error {
		var stream = new StringInputStream (file);
		if (!stream.has_string (offset + MAGIC_OFFSET, MAGIC_VALUE))
			return false;

		var header = stream.read_string_for_size (offset + MAGIC_OFFSET, HEADER_SIZE);

		return header.length == HEADER_SIZE && header.is_ascii ();
	}
}

errordomain Games.DreamcastError {
	INVALID_HEADER,
}
