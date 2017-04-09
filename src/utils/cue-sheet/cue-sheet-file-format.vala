// This file is part of GNOME Games. License: GPL-3.0+.

public enum Games.CueSheetFileFormat {
	INVALID,
	AIFF,
	BINARY,
	MOTOROLA,
	MP3,
	VORBIS,
	WAVE,
	UNKNOWN;

	public static CueSheetFileFormat parse_string (string? value) {
		switch (value) {
		case "AIFF":
			return CueSheetFileFormat.AIFF;
		case "BINARY":
			return CueSheetFileFormat.BINARY;
		case "MOTOROLA":
			return CueSheetFileFormat.MOTOROLA;
		case "MP3":
			return CueSheetFileFormat.MP3;
		case "VORBIS":
			return CueSheetFileFormat.VORBIS;
		case "WAVE":
			return CueSheetFileFormat.WAVE;
		case null:
			return CueSheetFileFormat.UNKNOWN;
		default:
			return CueSheetFileFormat.INVALID;
		}
	}
}
