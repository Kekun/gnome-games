// This file is part of GNOME Games. License: GPLv3

private class Games.MameGameUriAdapter : GameUriAdapter, Object {
	private const string SEARCHED_MIME_TYPE = "application/zip";
	private const string SPECIFIC_MIME_TYPE = "application/x-mame-rom";
	private const string MODULE_BASENAME = "libretro-mame.so";
	private const bool SUPPORTS_SNAPSHOTTING = false;

	public async Game game_for_uri (string uri) throws Error {
		var supported_games = MameGameInfo.get_supported_games ();

		var file = File.new_for_uri (uri);
		var game_id = file.get_basename ();
		game_id = /\.zip$/.replace (game_id, game_id.length, 0, "");

		if (!supported_games.contains (game_id))
			throw new MameError.INVALID_GAME_ID (_("Invalid MAME game id '%s' for '%s'."), game_id, uri);

		var uid_string = @"mame-$game_id".down ();
		var uid = new GenericUid (uid_string);

		var info = supported_games[game_id];
		var title_string = info.name;
		title_string = title_string.split ("(")[0];
		title_string = title_string.strip ();
		var title = new GenericTitle (title_string);

		var icon = new DummyIcon ();
		var cover = new LocalCover (uri);
		var runner = new RetroRunner.with_mime_types (uri, uid, { SEARCHED_MIME_TYPE, SPECIFIC_MIME_TYPE }, MODULE_BASENAME, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}
