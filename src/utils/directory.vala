// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.Directory : Object {
	public delegate bool FileInfoTest (FileInfo file_info) throws Error;

	private GLib.File file;

	public Directory (GLib.File file) {
		this.file = file;
	}

	public void @foreach (string attributes, FileInfoTest file_info_test) throws Error {
		var enumerator = file.enumerate_children (attributes, FileQueryInfoFlags.NONE);
		for (var file_info = enumerator.next_file () ; file_info != null ; file_info = enumerator.next_file ())
			if (file_info_test (file_info))
				return;
	}
}
