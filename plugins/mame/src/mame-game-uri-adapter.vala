// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.MameGameUriAdapter : GameUriAdapter, Object {
	private const string SEARCHED_MIME_TYPE = "application/zip";
	private const string SPECIFIC_MIME_TYPE = "application/x-mame-rom";
	private const string PLATFORM = "MAME";

	public async Game game_for_uri (string uri) throws Error {
		var supported_games = yield MameGameInfo.get_supported_games ();

		var file = File.new_for_uri (uri);
		var game_id = file.get_basename ();
		game_id = /\.zip$/.replace (game_id, game_id.length, 0, "");

		if (!supported_games.contains (game_id))
			throw new MameError.INVALID_GAME_ID (_("Invalid MAME game id “%s” for “%s”."), game_id, uri);

		var uid_string = @"mame-$game_id".down ();
		var uid = new GenericUid (uid_string);

		var info = supported_games[game_id];
		var title_string = info.name;
		title_string = title_string.split ("(")[0];
		title_string = title_string.strip ();
		var title = new GenericTitle (title_string);

		var icon = new DummyIcon ();
		var cover = new LocalCover (uri);
		var core_source = new RetroCoreSource (PLATFORM, { SEARCHED_MIME_TYPE, SPECIFIC_MIME_TYPE });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}
