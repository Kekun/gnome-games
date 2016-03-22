// This file is part of GNOME Games. License: GPLv3

private class Games.MameGame : Object, Game {
	private const string FINGERPRINT_PREFIX = "mame";
	private const string MODULE_BASENAME = "libretro-mame.so";

	private FingerprintUid _uid;
	public FingerprintUid uid {
		get {
			if (_uid != null)
				return _uid;

			_uid = new FingerprintUid (uri, FINGERPRINT_PREFIX);

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

	public MameGame (string uri) throws Error {
		this.uri = uri;

		var file = File.new_for_uri (uri);
		path = file.get_path ();

		var id = file.get_basename ();
		id = /\.zip$/.replace (id, id.length, 0, "");

		var supported_games = MameGameInfo.get_supported_games ();
		if (!supported_games.contains (id))
			throw new MameError.INVALID_GAME_ID ("Invalid MAME game id '%s' for '%s'", id, uri);

		var info = supported_games[id];
		_name = info.name;
		_name = _name.split ("(")[0];
		_name = _name.strip ();
	}

	public Runner get_runner () throws Error {
		var uid_string = uid.get_uid ();

		return new RetroRunner (MODULE_BASENAME, path, uid_string);
	}
}
