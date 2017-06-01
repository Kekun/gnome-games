// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.PlayStationGameFactory : Object, UriGameFactory {
	private const string CUE_MIME_TYPE = "application/x-cue";
	private const string PHONY_MIME_TYPE = "application/x-playstation-rom";
	private const string PLATFORM = "PlayStation";
	private const string ICON_NAME = "media-optical-symbolic";
	private const string GAMEINFO = "resource:///org/gnome/Games/plugin/playstation/playstation.gameinfo.xml";

	private static GameinfoDoc gameinfo;

	private HashTable<string, Media> media_for_disc_id;
	private HashTable<Uri, Game> game_for_uri;
	private HashTable<string, Game> game_for_disc_set_id;
	private GenericSet<Game> games;


	public PlayStationGameFactory () {
		media_for_disc_id = new HashTable<string, Media> (str_hash, str_equal);
		game_for_uri = new HashTable<Uri, Game> (Uri.hash, Uri.equal);
		game_for_disc_set_id = new HashTable<string, Game> (GLib.str_hash, GLib.str_equal);
		games = new GenericSet<Game> (direct_hash, direct_equal);
	}

	public string[] get_mime_types () {
		return { CUE_MIME_TYPE };
	}

	public async Game? query_game_for_uri (Uri uri) {
		Idle.add (this.query_game_for_uri.callback);
		yield;

		if (game_for_uri.contains (uri))
			return game_for_uri[uri];

		return null;
	}

	public async void add_uri (Uri uri) {
		try {
			add_uri_with_error (uri);
		}
		catch (Error e) {
			debug (e.message);
		}
	}

	// TODO support unknown games (not in DB)
	private void add_uri_with_error (Uri uri) throws Error {
		if (game_for_uri.contains (uri))
			return;

		var file = uri.to_file ();
		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();

		File bin_file;
		switch (mime_type) {
		case CUE_MIME_TYPE:
			var cue = new CueSheet (file);
			if (cue.tracks_number == 0)
				return;

			var track = cue.get_track (0);
			if (track.track_mode != CueSheetTrackMode.MODE1_2352 &&
			    track.track_mode != CueSheetTrackMode.MODE2_2352)
				return;

			bin_file = track.file.file;

			break;
		// TODO Add support for binary files.
		default:
			return;
		}

		var header = new PlayStationHeader (bin_file);
		header.check_validity ();
		var disc_id = header.disc_id;

		var gameinfo = get_gameinfo ();
		var disc_set_id = gameinfo.get_disc_set_id_for_disc_id (disc_id);

		return_if_fail (media_for_disc_id.contains (disc_id) == game_for_disc_set_id.contains (disc_set_id));

		// Check whether we already have a media and by extension a media set
		// and a game for this disc ID. If such a case, simply add the new URI.
		if (media_for_disc_id.contains (disc_id)) {
			var media = media_for_disc_id.lookup (disc_id);
			media.add_uri (uri);
			game_for_uri[uri] = game_for_disc_set_id[disc_set_id];

			return;
		}

		// A game correspond to this URI but we don't have it yet: create it.

		var new_medias = new HashTable<string, Media> (str_hash, str_equal);
		Media[] new_medias_array = {};
		var new_disc_ids = gameinfo.get_disc_set_ids_for_disc_id (disc_id);
		foreach (var new_disc_id in new_disc_ids) {
			assert (!media_for_disc_id.contains (new_disc_id));

			var title = new GameinfoDiscIdDiscTitle (gameinfo, new_disc_id);
			var media = new Media (title);
			new_medias_array += media;
			new_medias[new_disc_id] = media;
		}

		var media = new_medias.lookup (disc_id);
		media.add_uri (uri);

		var media_set = new MediaSet ();
		foreach (var game_media in new_medias_array)
			media_set.add_media (game_media);
		media_set.icon = GLib.Icon.new_for_string (ICON_NAME);
		var game = create_game (media_set, disc_set_id, uri);

		// Creating the Medias, MediaSet and Game worked, we can save them.

		foreach (var new_disc_id in new_medias.get_keys ())
			media_for_disc_id[new_disc_id] = new_medias[new_disc_id];

		game_for_uri[uri] = game;
		game_for_disc_set_id[disc_set_id] = game;
		games.add (game);
		game_added (game);
	}

	public async void foreach_game (GameCallback game_callback) {
		games.foreach ((game) => game_callback (game));
	}

	private Game create_game (MediaSet media_set, string disc_set_id, Uri uri) throws Error {
		var gameinfo = get_gameinfo ();
		var uid = new PlayStationUid (disc_set_id);
		var title = new CompositeTitle ({
			new GameinfoDiscIdGameTitle (gameinfo, disc_set_id),
			new FilenameTitle (uri)
		});
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, PHONY_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var input_capabilities = new GameinfoDiscIdInputCapabilities (gameinfo, disc_set_id);
		var core_source = new RetroCoreSource (PLATFORM, { CUE_MIME_TYPE, PHONY_MIME_TYPE });
		var runner = new RetroRunner.for_media_set_and_input_capabilities (core_source, media_set, uid, input_capabilities, title);

		return new GenericGame (title, icon, cover, runner);
	}

	private static GameinfoDoc get_gameinfo () throws Error {
		if (gameinfo != null)
			return gameinfo;

		var file = File.new_for_uri (GAMEINFO);
		var input_stream = file.read ();

		input_stream.seek (0, SeekType.END);
		var length = input_stream.tell ();
		input_stream.seek (0, SeekType.SET);

		var buffer = new uint8[length];
		size_t size = 0;

		input_stream.read_all (buffer, out size);

		gameinfo = new GameinfoDoc.from_data (buffer);

		return gameinfo;
	}
}
