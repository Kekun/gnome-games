// This file is part of GNOME Games. License: GPLv3

private class Games.LoveGame : Object, Game {
	private const size_t BLOCK_SIZE = 4096;

	private string _name;
	public string name {
		get { return _name; }
	}

	public Icon? icon {
		get { return love_icon; }
	}

	private static Icon? love_icon;

	private string path;

	static construct {
		try {
			love_icon = Icon.new_for_string ("love");
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

	public LoveGame (string uri) {
		var file = File.new_for_uri (uri);
		path = file.get_path ();

		var config_file = parse_package (path);
		if (config_file != null)
			parse_config_file (config_file);

		if (name == null) {
			var name = file.get_basename ();
			name = name.split (".")[0];
			name = name.split ("(")[0];
			_name = name.strip ();
		}
	}

	public string? parse_package (string path) {
		Archive.Read archive = new Archive.Read ();

		archive.support_filter_all ();
		archive.support_format_all ();

		var result = archive.open_filename(path, BLOCK_SIZE);
		if (result != Archive.Result.OK)
			return null; // FIXME: Should throw error.

		var is_valid = false;
		string? config_file = null;

		weak Archive.Entry entry;
		while(archive.next_header(out entry) == Archive.Result.OK) {
			var file_path = entry.pathname ();
			switch (file_path) {
			case "main.lua":
				is_valid = true;

				break;
			case "conf.lua":
				config_file = read_config_file (archive);

				break;
			}
		}

		if (!is_valid)
			return null; // FIXME: Should throw error.

		return config_file;
	}

	public string read_config_file (Archive.Read archive) {
		string config = "";

		char buffer[BLOCK_SIZE];
		while (archive.read_data (buffer, BLOCK_SIZE) != 0)
			config += (string) buffer;

		return config;
	}

	public void parse_config_file (string config_file) {
		var regex = /^\s*[^\s]+\.([^\s\.]+)\s*=\s*(.+?)\s*$/;

		var lines = config_file.split ("\n");
		MatchInfo match_info;
		foreach (var line in lines)
			if (regex.match (line, RegexMatchFlags.ANCHORED, out match_info)) {
				var key = match_info.fetch (1);
				var value = match_info.fetch (2);
				parse_config_line (key, value);
			}
	}

	public void parse_config_line (string? key, string? value) {
		switch (key) {
		case "title":
			_name = value.substring (1, -2);
			_name = value[1:-1];

			break;
		}
	}

	public Runner get_runner () throws RunError {
		string[] args = { "love", path };

		return new CommandRunner (args);
	}
}
