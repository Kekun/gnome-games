// This file is part of GNOME Games. License: GPLv3

private class Games.DummyGame : Object, Game {
	private string _name;
	public string name {
		get { return _name; }
	}

	public Icon? icon {
		get { return null; }
	}

	public DummyGame (string name) {
		_name = name;
	}
}
