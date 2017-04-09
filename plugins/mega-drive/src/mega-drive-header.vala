// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: https://en.wikibooks.org/wiki/Genesis_Programming
private class Games.MegaDriveHeader : Object {
	public const size_t HEADER_LENGTH = 0x200;

	private const size_t[] POSSIBLE_HEADER_OFFSETS = { 0x0, 0x10 };

	private const size_t CD_OFFSET = 0x0;

	private const size_t SYSTEM_OFFSET = 0x100;
	// A game with a weird character at the 16th position was found so
	// let's just use the 15 first chars.
	private const size_t SYSTEM_SIZE = 0xf;

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

	private MegaDriveSystem? _system;
	public MegaDriveSystem system {
		get {
			if (_system != null)
				return _system;

			try {
				_system = parse_system ();
			}
			catch (Error e) {
				debug (e.message);

				_system = MegaDriveSystem.INVALID;
			}

			return _system;
		}
	}

	private File file;
	private size_t? offset;

	public MegaDriveHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		if (system == MegaDriveSystem.INVALID)
			throw new MegaDriveError.INVALID_HEADER (_("The file doesn’t have a Genesis/Sega 32X/Sega CD/Sega Pico header."));
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

			throw new MegaDriveError.INVALID_HEADER (_("The file doesn’t have a Genesis/Sega 32X/Sega CD/Sega Pico header."));
	}

	private MegaDriveSystem parse_system () throws Error {
		var stream = new StringInputStream (file);

		var offset = get_offset ();
		var is_cd = stream.has_string (offset + CD_OFFSET, "SEGADISCSYSTEM");
		var system_string = stream.read_string_for_size (offset + SYSTEM_OFFSET, SYSTEM_SIZE);
		system_string = system_string.chomp ();

		switch (system_string) {
		case "SEGA MEGA DRIVE":
		case "SEGA GENESIS":
		case " SEGA MEGA DRIV":
		case "SEGA_MEGA_DRIVE":
		case "SEGA are Regist":
			return is_cd ? MegaDriveSystem.MEGA_CD : MegaDriveSystem.MEGA_DRIVE;
		case "SEGA 32X":
			return is_cd ? MegaDriveSystem.MEGA_CD_32X : MegaDriveSystem.32X;
		case "SEGA PICO":
			return is_cd ? MegaDriveSystem.INVALID : MegaDriveSystem.PICO;
		default:
			return MegaDriveSystem.INVALID;
		}
	}

	public bool is_mega_drive () {
		switch (system) {
		case MegaDriveSystem.MEGA_DRIVE:
		case MegaDriveSystem.MEGA_CD:
			return true;
		default:
			return false;
		}
	}

	public bool is_32x () {
		switch (system) {
		case MegaDriveSystem.32X:
		case MegaDriveSystem.MEGA_CD_32X:
			return true;
		default:
			return false;
		}
	}

	public bool is_pico () {
		return system == MegaDriveSystem.PICO;
	}
}

errordomain Games.MegaDriveError {
	INVALID_HEADER,
	INVALID_CUE_SHEET,
	INVALID_FILE_TYPE,
}
