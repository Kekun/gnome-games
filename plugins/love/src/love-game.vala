// This file is part of GNOME Games. License: GPLv3

private class Games.LoveGame : Object, Game {
	private string _name;
	public string name {
		get { return _name; }
	}

	public GLib.Icon? icon {
		get { return love_icon; }
	}

	private static GLib.Icon? love_icon;

	private string path;

	static construct {
		try {
			love_icon = GLib.Icon.new_for_string ("love");
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

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
	}

	public Runner get_runner () throws Error {
		string[] args = { "love", path };

		return new CommandRunner (args);
	}
}
