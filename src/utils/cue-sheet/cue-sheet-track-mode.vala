// This file is part of GNOME Games. License: GPL-3.0+.

public enum Games.CueSheetTrackMode {
	INVALID,
	AUDIO,
	CDG,
	MODE1_2048,
	MODE1_2352,
	MODE2_2336,
	MODE2_2352,
	CDI_2336,
	CDI_2352;

	public static CueSheetTrackMode parse_string (string value) {
		switch (value) {
		case "AUDIO":
			return CueSheetTrackMode.AUDIO;
		case "CDG":
			return CueSheetTrackMode.CDG;
		case "MODE1/2048":
			return CueSheetTrackMode.MODE1_2048;
		case "MODE1/2352":
			return CueSheetTrackMode.MODE1_2352;
		case "MODE2/2336":
			return CueSheetTrackMode.MODE2_2336;
		case "MODE2/2352":
			return CueSheetTrackMode.MODE2_2352;
		case "CDI/2336":
			return CueSheetTrackMode.CDI_2336;
		case "CDI/2352":
			return CueSheetTrackMode.CDI_2352;
		default:
			return CueSheetTrackMode.INVALID;
		}
	}

	public bool is_mode1 () {
		switch (this) {
		case CueSheetTrackMode.MODE1_2048:
		case CueSheetTrackMode.MODE1_2352:
			return true;
		default:
			return false;
		}
	}
}
