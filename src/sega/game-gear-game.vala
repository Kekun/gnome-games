// This file is part of GNOME Games. License: GPLv3

private class Games.GameGearGame : Object, Game {
	private const string MODULE_BASENAME = "libretro-game-gear.so";

	private string _uid;
	public string uid {
		get {
			if (_uid != null)
				return _uid;

			_uid = Checksum.compute_for_string (ChecksumType.MD5, uri);

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

	public Gdk.Pixbuf? cover {
		get { return null; }
	}

	public Gdk.Pixbuf? screenshot {
		get { return null; }
	}

	public bool running {
		get { return false; }
	}

	private string uri;
	private string path;

	public GameGearGame (string uri) throws Error {
		this.uri = uri;

		var file = File.new_for_uri (uri);
		path = file.get_path ();

		var header = new MasterSystemHeader (file);
		var region_code = header.region_code;
		if (region_code != MasterSystemRegion.GG_JAPAN &&
		    region_code != MasterSystemRegion.GG_EXPORT &&
		    region_code != MasterSystemRegion.GG_INTERNATIONAL)
			throw new MasterSystemError.INVALID_REGION ("The file isn't a Game Gear game.");

		var name = file.get_basename ();
		name = /\.gg$/.replace (name, name.length, 0, "");
		name = name.split ("(")[0];
		_name = name.strip ();
	}

	public Runner get_runner () throws RunError {
		return new RetroRunner (MODULE_BASENAME, path, uid);
	}
}
