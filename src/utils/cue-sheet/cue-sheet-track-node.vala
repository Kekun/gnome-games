// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CueSheetTrackNode : Object {
	public CueSheetFileNode file { construct; get; }
	public int track_number { construct; get; }
	public CueSheetTrackMode track_mode { construct; get; }

	public CueSheetTrackNode (CueSheetFileNode file, int track_number, CueSheetTrackMode track_mode) {
		Object (file: file, track_number: track_number, track_mode: track_mode);
	}
}
