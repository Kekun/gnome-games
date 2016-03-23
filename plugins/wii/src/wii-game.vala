// This file is part of GNOME Games. License: GPLv3

private class Games.WiiGame : Object, Game {
	private const string MODULE_BASENAME = "libretro-wii.so";

	private WiiUid _uid;
	public WiiUid uid {
		get {
			if (_uid != null)
				return _uid;

			_uid = new WiiUid (header);

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
	private string path;
	private WiiHeader header;

	public WiiGame (string uri) throws Error {
		this.uri = uri;

		var file = File.new_for_uri (uri);
		path = file.get_path ();

		header = new WiiHeader (file);
		header.check_validity ();

		var name = file.get_basename ();
		name = /\.iso$/.replace (name, name.length, 0, "");
		name = name.split ("(")[0];
		_name = name.strip ();
	}

	public Runner get_runner () throws Error {
		var uid_string = uid.get_uid ();

		return new RetroRunner (MODULE_BASENAME, path, uid_string);
	}
}
