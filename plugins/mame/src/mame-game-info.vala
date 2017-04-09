// This file is part of GNOME Games. License: GPL-3.0+.

private struct Games.MameGameInfo {
	private static HashTable<string, MameGameInfo?> supported_games;
	private static Regex game_regex;

	public string id;
	public string name;

	public static async HashTable<string, MameGameInfo?> get_supported_games () throws Error {
		if (supported_games != null)
			return supported_games;

		supported_games = new HashTable<string, MameGameInfo?> (str_hash, str_equal);

		var bytes = resources_lookup_data ("/org/gnome/Games/plugins/mame/supported-games", ResourceLookupFlags.NONE);
		var text = (string) bytes.get_data ();

		if (game_regex == null) {
			// Data is of the form: GAME[L](YEAR,NAME,PARENT,MACHINE,INPUT,CLASS,INIT,MONITOR,COMPANY,FULLNAME,FLAGS[,LAYOUT])
			var simple = " *([^,]+) *";
			var quoted = " *\" *(.*?) *\" *";
			var pattern = @"$simple,$simple,$simple,$simple,$simple,$simple,$simple,$simple,$quoted,$quoted,$simple(?:,$simple)?";
			game_regex = new Regex ("^GAMEL?\\(" + pattern + "\\) *$");

			Idle.add (get_supported_games.callback);
			yield;
		}

		foreach (var line in text.split ("\n")) {
			MatchInfo match_info;
			if (!game_regex.match (line, 0, out match_info))
				continue;

			var game_info = MameGameInfo() {
				id = cleanup_string (match_info.fetch (2)), // NAME
				name = cleanup_string (match_info.fetch (10)) // FULLNAME
			};
			supported_games[game_info.id] = game_info;

			Idle.add (get_supported_games.callback);
			yield;
		}

		return supported_games;
	}

	private static Regex cleanup_string_regex;
	private static string cleanup_string (string text) {
		if (cleanup_string_regex == null)
			cleanup_string_regex = /^[\s"]*(.*?)[\s"]*$/;

		MatchInfo match_info;
		if (!cleanup_string_regex.match (text, 0, out match_info))
			return text;

		return match_info.fetch (1) ?? text;
	}
}
