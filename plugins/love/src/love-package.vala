// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.LovePackage : Object {
	private const size_t BLOCK_SIZE = 4096;

	private string uri;
	private HashTable<string, string> config;

	public LovePackage (string uri) throws Error {
		this.uri = uri;

		if (!contains_file ("main.lua"))
			throw new LoveError.INVALID_PACKAGE (_("This doesn’t represent a valid LÖVE package: “%s”."), uri);

		var config_file = get_file_string ("conf.lua");
		if (config_file == null)
			throw new LoveError.INVALID_PACKAGE (_("This doesn’t represent a valid LÖVE package: “%s”."), uri);

		var regex = /^\s*[^\s]+\.([^\s\.]+)\s*=\s*(.+?)\s*$/;

		config = new HashTable<string, string> (GLib.str_hash, GLib.str_equal);

		var lines = config_file.split ("\n");
		MatchInfo match_info;
		foreach (var line in lines)
			if (regex.match (line, RegexMatchFlags.ANCHORED, out match_info)) {
				var key = match_info.fetch (1);
				var lua_value = match_info.fetch (2);
				config[key] = lua_value;
			}
	}

	public string get_uri () {
		return uri;
	}

	public string? get_config (string key) {
		if (!config.contains (key))
			return null;

		return parse_string (config[key]);
	}

	public bool contains_file (string path_in_archive) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		Archive.Read archive = new Archive.Read ();

		archive.support_filter_all ();
		archive.support_format_all ();

		var result = archive.open_filename(path, BLOCK_SIZE);
		if (result != Archive.Result.OK)
			return false;

		weak Archive.Entry entry;
		while(archive.next_header(out entry) == Archive.Result.OK) {
			var file_path = entry.pathname ();
			if (file_path != path_in_archive)
				continue;

			return true;
		}

		return false;
	}

	public InputStream? get_file_input_stream (string path_in_archive) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		Archive.Read archive = new Archive.Read ();

		archive.support_filter_all ();
		archive.support_format_all ();

		var result = archive.open_filename(path, BLOCK_SIZE);
		if (result != Archive.Result.OK)
			return null;

		weak Archive.Entry entry;
		while(archive.next_header(out entry) == Archive.Result.OK) {
			var file_path = entry.pathname ();
			if (file_path != path_in_archive)
				continue;

			var size = entry.size ();

			return read_file_to_input_stream (archive, size);
		}

		return null;
	}

	public string? get_file_string (string path_in_archive) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		Archive.Read archive = new Archive.Read ();

		archive.support_filter_all ();
		archive.support_format_all ();

		var result = archive.open_filename(path, BLOCK_SIZE);
		if (result != Archive.Result.OK)
			return null;

		weak Archive.Entry entry;
		while(archive.next_header(out entry) == Archive.Result.OK) {
			var file_path = entry.pathname ();
			if (file_path != path_in_archive)
				continue;

			return read_file_to_string (archive);
		}

		return null;
	}

	private InputStream read_file_to_input_stream (Archive.Read archive, int64 size) {
		uint8[] content = new uint8[size];
		archive.read_data (content, (size_t) size);

		return new MemoryInputStream.from_data (content);
	}

	private string read_file_to_string (Archive.Read archive) {
		string content = "";

		char buffer[BLOCK_SIZE];
		while (archive.read_data (buffer, BLOCK_SIZE) != 0)
			content += (string) buffer;

		return content;
	}

	private string? parse_string (string lua_value) {
		if (lua_value.length < 2)
			return null;

		if (!lua_value.has_prefix ("\""))
			return null;

		if (!lua_value.has_suffix ("\""))
			return null;

		return lua_value[1:-1];
	}
}
