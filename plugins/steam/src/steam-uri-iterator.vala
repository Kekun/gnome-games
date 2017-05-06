// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamUriIterator : Object, UriIterator {
	private string[] directories;
	private int directory_index;
	private FileEnumerator? enumerator;
	private Uri? uri;

	internal SteamUriIterator (string[] directories) {
		this.directories = directories;
		directory_index = 0;
		uri = null;
		enumerator = null;
	}

	public new Uri? get () {
		return uri;
	}

	public bool next () {
		while (directory_index < directories.length) {
			if (try_next_for_directory (directories[directory_index]))
				return true;

			directory_index++;
		}

		return false;
	}

	private bool try_next_for_directory (string directory) {
		try {
			if (next_for_directory (directory))
				return true;
		}
		catch (Error e) {
			debug (e.message);
		}

		uri = null;
		enumerator = null;

		return false;
	}

	private bool next_for_directory (string directory) throws Error {
		if (enumerator == null) {
			var file = File.new_for_path (directory);
			enumerator = file.enumerate_children (FileAttribute.STANDARD_NAME, 0);
		}


		FileInfo info = null;
		do {
			info = enumerator.next_file ();
		} while (info != null && !info.get_name ().has_suffix (".acf"));
		if (info == null)
			return false;

		var filename = Path.build_filename (directory, info.get_name ());
		var file_uri = Filename.to_uri (filename);
		uri = new Uri (@"steam+$file_uri");

		return true;
	}
}
