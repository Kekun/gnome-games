// This file is part of GNOME Games. License: GPLv3

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

	private FileInputStream stream;

	public MasterSystemHeader (File file) throws Error {
		stream = file.read ();

		check_validity ();
	}

	public void check_validity () throws MasterSystemError {
		try {
			stream.seek (MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new MasterSystemError.INVALID_SIZE (@"Invalid Master System header size: $(e.message)");
		}

		var buffer = new uint8[MAGIC_VALUE.length];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new MasterSystemError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;
		if (magic != MAGIC_VALUE)
			throw new MasterSystemError.INVALID_HEADER ("The file doesn't have a Master System header.");
	}
}

public enum Games.MasterSystemRegion {
	INVALID = 0,
	SMS_JAPAN = 3,
	SMS_EXPORT,
	GG_JAPAN,
	GG_EXPORT,
	GG_INTERNATIONAL,
}

errordomain Games.MasterSystemError {
	INVALID_SIZE,
	INVALID_HEADER,
}
