// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: https://en.wikibooks.org/wiki/Genesis_Programming
private class Games.SegaCDHeader : Object {
	public const size_t HEADER_LENGTH = 0x200;

	private const size_t[] POSSIBLE_HEADER_OFFSETS = { 0x0, 0x10 };

	private const size_t CD_OFFSET = 0x0;

	private const size_t SYSTEM_OFFSET = 0x100;
	// A game with a weird character at the 16th position was found so
	// let's just use the 15 first chars.
	private const size_t SYSTEM_SIZE = 0xf;

	private SegaCDSystem? _system;
	public SegaCDSystem system {
		get {
			if (_system != null)
				return _system;

			try {
				_system = parse_system ();
			}
			catch (Error e) {
				debug (e.message);

				_system = SegaCDSystem.INVALID;
			}

			return _system;
		}
	}

	private File file;
	private size_t? offset;

	public SegaCDHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		if (system == SegaCDSystem.INVALID)
			throw new SegaCDError.INVALID_HEADER (_("The file doesn’t have a Genesis/Sega 32X/Sega CD/Sega Pico header."));
	}

	public size_t get_offset () throws Error {
		if (offset != null)
			return offset;

		var stream = new StringInputStream (file);

		foreach (var possible_offset in POSSIBLE_HEADER_OFFSETS) {
			var system_string = stream.read_string_for_size (possible_offset + SYSTEM_OFFSET, SYSTEM_SIZE);
			system_string = system_string.strip ();
			if (system_string.has_prefix ("SEGA")) {
				offset = possible_offset;

				return offset;
			}
		}

			throw new SegaCDError.INVALID_HEADER (_("The file doesn’t have a Genesis/Sega 32X/Sega CD/Sega Pico header."));
	}

	private SegaCDSystem parse_system () throws Error {
		var stream = new StringInputStream (file);

		var offset = get_offset ();
		if (!stream.has_string (offset + CD_OFFSET, "SEGADISCSYSTEM"))
			return SegaCDSystem.INVALID;

		var system_string = stream.read_string_for_size (offset + SYSTEM_OFFSET, SYSTEM_SIZE);
		system_string = system_string.chomp ();

		switch (system_string) {
		case "SEGA MEGA DRIVE":
		case "SEGA GENESIS":
		case " SEGA MEGA DRIV":
		case "SEGA_SEGA_CD":
		case "SEGA are Regist":
			return SegaCDSystem.SEGA_CD;
		case "SEGA 32X":
			return SegaCDSystem.SEGA_CD_32X;
		default:
			return SegaCDSystem.INVALID;
		}
	}

	public bool is_sega_cd () {
		switch (system) {
		case SegaCDSystem.SEGA_CD:
			return true;
		default:
			return false;
		}
	}

	public bool is_sega_cd_32x () {
		switch (system) {
		case SegaCDSystem.SEGA_CD_32X:
			return true;
		default:
			return false;
		}
	}
}

errordomain Games.SegaCDError {
	INVALID_HEADER,
	INVALID_CUE_SHEET,
	INVALID_FILE_TYPE,
}
