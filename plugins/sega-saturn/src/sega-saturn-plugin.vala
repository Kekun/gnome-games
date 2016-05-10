// This file is part of GNOME Games. License: GPLv3

private class Games.SegaSaturnPlugin : Object, Plugin {
	private const string MIME_TYPE = "application/x-saturn-rom";
	private const string MODULE_BASENAME = "libretro-saturn.so";
	private const bool SUPPORTS_SNAPSHOTTING = false;

	public GameSource get_game_source () throws Error {
		var query = new MimeTypeTrackerQuery (MIME_TYPE, game_for_uri);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var file = File.new_for_uri (uri);
		var header = new SegaSaturnHeader (file);
		header.check_validity ();

		var cue = get_associated_cue_sheet (file);
		var real_uri = cue ?? uri;

		var uid = new SegaSaturnUid (header);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MIME_TYPE);
		var cover = new GriloCover (media, uid);
		var runner =  new RetroRunner (MODULE_BASENAME, uri, uid, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}

	private static string? get_associated_cue_sheet (File file) throws Error {
		var directory = file.get_parent ();
		var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

		FileInfo file_info;
		while ((file_info = enumerator.next_file ()) != null) {
			var name = file_info.get_name ();
			var child = directory.resolve_relative_path (name);
			var child_info = child.query_info ("*", FileQueryInfoFlags.NONE);
			var type = child_info.get_content_type ();

			if (type == "application/x-cue" && cue_contains_file (child, file))
				return child.get_uri ();
		}

		return null;
	}

	private static bool cue_contains_file (File cue, File file) throws Error {
		var file_input_stream = cue.read ();
		var data_input_stream = new DataInputStream (file_input_stream);

		var regex = /FILE\s+"(.*?)"\s+BINARY/;

		string line;
		MatchInfo match_info;
		while ((line = data_input_stream.read_line (null)) != null) {
			if (regex.match (line, RegexMatchFlags.ANCHORED, out match_info))
				if (match_info.fetch (1) == file.get_basename ())
					return true;
		}

		return false;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.SegaSaturnPlugin);
}
