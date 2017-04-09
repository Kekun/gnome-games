// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DummyGame : Object, Game {
	private string _name;
	public string name {
		get { return _name; }
	}

	public DummyGame (string name) {
		_name = name;
	}

	public DummyGame.for_uri (string uri) {
		var file = File.new_for_uri (uri);
		var name = file.get_basename ();
		name = name.split (".")[0];
		name = name.split ("(")[0];
		_name = name.strip ();
	}

	public Icon get_icon () {
		return new DummyIcon ();
	}

	public Cover get_cover () {
		return new DummyCover ();
	}

	public Runner get_runner () throws Error {
		return new DummyRunner ();
	}
}
