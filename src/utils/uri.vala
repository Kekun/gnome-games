// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.Uri {
	private static Regex scheme_regex;

	private string uri;

	public Uri (string uri) {
		this.uri = uri;
	}

	public Uri.from_uri_and_scheme (Uri uri, string scheme) throws Error {
		this.uri = scheme_regex.replace (uri.uri, -1, 0, scheme + ":");
	}

	public Uri.from_file (File file) {
		uri = file.get_uri ();
	}

	static construct {
		scheme_regex = /^([a-z][a-z0-9\+\.\-]*):/i;
	}

	public static uint hash (Uri uri) {
		return str_hash (uri.uri);
	}

	public static bool equal (Uri a, Uri b) {
		return str_equal (a.uri, b.uri);
	}

	public string to_string () {
		return uri;
	}

	public File to_file () {
		return File.new_for_uri (uri);
	}

	public string get_scheme () throws Error {
		MatchInfo info;
		if (!scheme_regex.match (uri, 0, out info))
			throw new UriError.INVALID_SCHEME ("The URI doesn't have a valid scheme: %s.", uri);

		return info.fetch (1);
	}
}
