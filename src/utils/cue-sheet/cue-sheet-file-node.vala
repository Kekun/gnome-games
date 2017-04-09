// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CueSheetFileNode : Object {
	public string file_name { construct; get; }
	public CueSheetFileFormat file_format { construct; get; }

	public File file { construct; get; }

	public CueSheetFileNode (File file, CueSheetFileFormat file_format) {
		Object (file: file, file_format: file_format);
	}
}
