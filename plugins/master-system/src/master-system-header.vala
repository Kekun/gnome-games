// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: http://www.smspower.org/Development/ROMHeader
private class Games.MasterSystemHeader : Object {
	private const size_t MAGIC_OFFSET = 0x7ff0;
	private const string MAGIC_VALUE = "TMR SEGA";

	private const size_t REGION_CODE_OFFSET = 0x7fff;
	private const uint8 REGION_CODE_MASK = 0xf0;

	private MasterSystemRegion? _region_code;
	public MasterSystemRegion region_code {
		get {
			if (_region_code != null)
				return _region_code;

			FileInputStream stream;
			try {
				stream = file.read ();
			}
			catch (Error e) {
				_region_code = MasterSystemRegion.INVALID;

				return _region_code;
			}

			try {
				stream.seek (REGION_CODE_OFFSET, SeekType.SET);
			}
			catch (Error e) {
				_region_code = MasterSystemRegion.INVALID;

				return _region_code;
			}

			uint8 buffer[1];
			try {
				stream.seek (REGION_CODE_OFFSET, SeekType.SET);
				stream.read (buffer);
			}
			catch (Error e) {
				_region_code = MasterSystemRegion.INVALID;

				return _region_code;
			}

			var region_value = (buffer[0] & REGION_CODE_MASK) >> 4;

			if (MasterSystemRegion.SMS_JAPAN <= region_value &&
			    region_value <= MasterSystemRegion.GG_INTERNATIONAL)
				_region_code = (MasterSystemRegion) region_value;

			if (_region_code == null)
				_region_code = MasterSystemRegion.INVALID;

			return _region_code;
		}
	}

	private File file;

	public MasterSystemHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		var stream = new StringInputStream (file);
		if (!stream.has_string (MAGIC_OFFSET, MAGIC_VALUE))
			throw new MasterSystemError.INVALID_HEADER (_("The file doesn’t have a Master System header."));
	}

	public bool is_master_system () {
		switch (region_code) {
		case MasterSystemRegion.SMS_JAPAN:
		case MasterSystemRegion.SMS_EXPORT:
			return true;
		default:
			return false;
		}
	}

	public bool is_game_gear () {
		switch (region_code) {
		case MasterSystemRegion.GG_JAPAN:
		case MasterSystemRegion.GG_EXPORT:
		case MasterSystemRegion.GG_INTERNATIONAL:
			return true;
		default:
			return false;
		}
	}
}

private enum Games.MasterSystemRegion {
	INVALID = 0,
	SMS_JAPAN = 3,
	SMS_EXPORT,
	GG_JAPAN,
	GG_EXPORT,
	GG_INTERNATIONAL,
}

errordomain Games.MasterSystemError {
	INVALID_HEADER,
}
