// This file is part of GNOME Games. License: GPLv3

private class Games.SegaSaturnGame : Object, Game {
	private const string MODULE_BASENAME = "libretro-saturn.so";

	private SegaSaturnUid _uid;
	public SegaSaturnUid uid {
		get {
			if (_uid != null)
				return _uid;

			_uid = new SegaSaturnUid (header);

			return _uid;
		}
	}

	private string _name;
	public string name {
		get { return _name; }
	}

	public Icon? icon {
		get { return null; }
	}

	private string uri;
	private SegaSaturnHeader header;

	public SegaSaturnGame (string uri) throws Error {
		var file = File.new_for_uri (uri);
		header = new SegaSaturnHeader (file);
		header.check_validity ();

		var cue = get_associated_cue_sheet (file);
		this.uri = cue ?? uri;

		file = File.new_for_uri (this.uri);
		var name = file.get_basename ();
		name = /\.(cue|iso|bin)$/.replace (name, name.length, 0, "");
		name = name.split ("(")[0];
		_name = name.strip ();
	}

	public Runner get_runner () throws Error {
		return new RetroRunner (MODULE_BASENAME, uri, uid);
	}

	private string? get_associated_cue_sheet (File file) throws Error {
		var directory = file.get_parent ();
		var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

		FileInfo file_info;
		while ((file_info = enumerator.next_file ()) != null) {
			var name = file_info.get_name ();
			var child = directory.resolve_relative_path (name);
			var child_info = child.query_info ("*", FileQueryInfoFlags.NONE);
			var type = child_info.get_content_type ();

			if (type == "application/x-cue" && cue_contains_file (child, file))
				return child.get_uri ();
		}

		return null;
	}

	private bool cue_contains_file (File cue, File file) throws Error {
		var file_input_stream = cue.read ();
		var data_input_stream = new DataInputStream (file_input_stream);

		var regex = /FILE\s+"(.*?)"\s+BINARY/;

		string line;
		MatchInfo match_info;
		while ((line = data_input_stream.read_line (null)) != null) {
			if (regex.match (line, RegexMatchFlags.ANCHORED, out match_info))
				if (match_info.fetch (1) == file.get_basename ())
					return true;
		}

		return false;
	}
}
