// This file is part of GNOME Games. License: GPL-3.0+.

namespace Games.Grep {
	public size_t[] get_offsets (string filename, string text) {
		var working_dir = Environment.get_current_dir ();
		string[] args = { "grep", "--byte-offset", "--only-matching", "--text", text, filename };
		var env = Environ.@get ();

		bool success = false;
		string output;

		try {
			success = Process.spawn_sync (working_dir, args, env,
				                          SpawnFlags.SEARCH_PATH, null,
				                          out output);
		}
		catch (SpawnError e) {
			return {};
		}

		if (!success)
			return {};

		size_t[] offsets = {};

		foreach (var line in output.split ("\n")) {
			var splitted_line = line.split (":");
			if (splitted_line.length != 2)
				continue;

			if (splitted_line[1] != text)
				continue;

			uint64 offset;
			if (!uint64.try_parse (splitted_line[0], out offset))
				continue;

			offsets += (size_t) offset;
		}

		return offsets;
	}
}
