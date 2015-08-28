// This file is part of GNOME Games. License: GPLv3

public enum Games.MasterSystemRegion {
	INVALID = 0,
	SMS_JAPAN = 3,
	SMS_EXPORT,
	GG_JAPAN,
	GG_EXPORT,
	GG_INTERNATIONAL,
}

errordomain Games.MasterSystemError {
	CANT_READ_FILE,
	INVALID_HEADER,
	INVALID_REGION,
}
