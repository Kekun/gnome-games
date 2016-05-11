// This file is part of GNOME Games. License: GPLv3

private class Games.LoveGame : Object, Game {
	private string _name;
	public string name {
		get { return _name; }
	}

	private string path;
	private LoveIcon icon;

	public LoveGame (string uri) throws Error {
		var package = new LovePackage (uri);

		var file = File.new_for_uri (uri);
		path = file.get_path ();

		_name = package.get_config ("title");

		if (name == null)
			_name = package.get_config ("identity");

		if (name == null) {
			var name = file.get_basename ();
			name = name.split (".")[0];
			name = name.split ("(")[0];
			_name = name.strip ();
		}

		icon = new LoveIcon (package);
	}

	public Icon get_icon () {
		return icon;
	}

	public Runner get_runner () throws Error {
		string[] args = { "love", path };

		return new CommandRunner (args);
	}
}
