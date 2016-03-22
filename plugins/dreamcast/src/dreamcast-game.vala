// This file is part of GNOME Games. License: GPLv3

private class Games.DreamcastGame : Object, Game {
	private const string MODULE_BASENAME = "libretro-dreamcast.so";

	private DreamcastUid _uid;
	public DreamcastUid uid {
		get {
			if (_uid != null)
				return _uid;

			_uid = new DreamcastUid (header);

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
	private DreamcastHeader header;

	public DreamcastGame (string uri) throws Error {
		this.uri = uri;

		var file = File.new_for_uri (uri);
		header = new DreamcastHeader (file);
		header.check_validity ();

		var name = file.get_basename ();
		name = /\.dc$/.replace (name, name.length, 0, "");
		name = name.split ("(")[0];
		_name = name.strip ();
	}

	public Runner get_runner () throws Error {
		return new RetroRunner (MODULE_BASENAME, uri, uid);
	}
}
