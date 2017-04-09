// This file is part of GNOME Games. License: GPL-3.0+.

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

		var stream = new StringInputStream (file);
		foreach (var offset in HEADER_OFFSETS)
			if (stream.has_string (offset, MAGIC_VALUE))
				header_offset = offset;

		if (header_offset == null)
			throw new SegaSaturnError.INVALID_HEADER (_("The file doesn’t have a Sega Saturn header."));

		return header_offset;
	}
}
