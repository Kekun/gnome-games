// This file is part of GNOME Games. License: GPLv3

public class Games.FilenameTitle : Object, Title {
	private static Regex filename_ext_regex;

	private string uri;

	static construct {
		filename_ext_regex = /\.\w+$/;
	}

	public FilenameTitle (string uri) {
		this.uri = uri;
	}

	public string get_title () throws Error {
		var file = File.new_for_uri (uri);
		var name = file.get_basename ();
		name = filename_ext_regex.replace (name, name.length, 0, "");
		name = name.split ("(")[0];
		name = name.strip ();

		return name;
	}
}
