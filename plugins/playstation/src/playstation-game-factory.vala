// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.PlayStationGameFactory : Object, UriGameFactory {
	private const string SEARCHED_MIME_TYPE = "application/x-cue";
	private const string SPECIFIC_MIME_TYPE = "application/x-playstation-rom";
	private const string PLATFORM = "PlayStation";
	private const string ICON_NAME = "media-optical-symbolic";
	private const string GAMEINFO = "resource:///org/gnome/Games/plugin/playstation/playstation.gameinfo.xml";

	private static GameinfoDoc gameinfo;

	private HashTable<string, string> discs;
	private HashTable<string, GenericSet<string>> disc_sets;
	private HashTable<string, Game> games;


	public PlayStationGameFactory () {
		discs = new HashTable<string, string> (GLib.str_hash, GLib.str_equal);
		disc_sets = new HashTable<string, GenericSet<string>> (GLib.str_hash, GLib.str_equal);
		games = new HashTable<string, Game> (GLib.str_hash, GLib.str_equal);
	}

	public bool is_cursor_valid (Tracker.Sparql.Cursor cursor) {
		var uri = cursor.get_string (0);

		return is_uri_valid (uri);
	}

	public bool is_uri_valid (string uri) {
		File file = File.new_for_uri(uri);

		return file.query_exists ();
	}

	public void add_uri (string uri) {
		string disc_id;

		try {
			disc_id = get_disc_id (uri);
		}
		catch (Error e) {
			return;
		}

		discs[disc_id] = uri;
	}

	public async void foreach_game (GameCallback game_callback) {
		GameinfoDoc gameinfo = null;
		try {
			gameinfo = get_gameinfo ();
		}
		catch (Error e) {
			warning (e.message);
		}

		discs.foreach((disc_id, uri) => {
			var disc_set_id = disc_id;

			try {
				if (gameinfo != null)
					disc_set_id = gameinfo.get_disc_set_id_for_disc_id (disc_id);
			}
			catch (Error e) {
				debug (_("Disc with disc_id %s is unknown"), disc_id);
			}

			if (!(disc_set_id in disc_sets))
				disc_sets[disc_set_id] = new GenericSet<string> (GLib.str_hash, GLib.str_equal);

			disc_sets[disc_set_id].add (disc_id);
		});

		disc_sets.foreach ((disc_set_id, disc_set) => {
			try {
				if (!(disc_set_id in games))
					games[disc_set_id] = game_for_disc_set (disc_set);
			}
			catch (Error e) {
				warning (e.message);
			}
		});

		games.foreach ((disc_set_id, game) => {
			game_callback (game);
		});
	}

	private string get_disc_id (string uri) throws Error {
		var cue_file = File.new_for_uri (uri);
		var cue_sheet = new CueSheet (cue_file);
		var cue_track_node = cue_sheet.get_track (0);
		var bin_file = cue_track_node.file.file;
		var header = new PlayStationHeader (bin_file);

		header.check_validity ();

		return header.disc_id;
	}

	private Game game_for_disc_set (GenericSet<string> disc_set) throws Error {
		Media[] medias = {};

		var gameinfo = get_gameinfo ();
		var disc_list = disc_set.get_values ();
		disc_list.sort_with_data ((disc_id_a, disc_id_b) => {
			int index_a;
			int index_b;
			try {
				index_a = gameinfo.get_disc_set_index_for_disc_id (disc_id_a);
				index_b = gameinfo.get_disc_set_index_for_disc_id (disc_id_b);
			}
			catch (Error e) {
				debug (e.message);

				return 0;
			}

			return (int) (index_a > index_b) - (int) (index_a < index_b);
		});

		disc_list.foreach ((disc_id) => {
			var uri = discs[disc_id];
			var title = new GameinfoDiscIdDiscTitle (gameinfo, disc_id);
			medias += new Media (uri, title);
		});

		var icon = GLib.Icon.new_for_string (ICON_NAME);
		var media_set = new MediaSet (medias, icon);

		var game = game_for_uris (media_set);

		return game;
	}

	private Game game_for_uris (MediaSet media_set) throws Error {
		var uri = media_set.get_selected_media (0).uri;
		var cue_file = File.new_for_uri (uri);
		var cue_sheet = new CueSheet (cue_file);
		var cue_track_node = cue_sheet.get_track (0);
		var bin_file = cue_track_node.file.file;
		var header = new PlayStationHeader (bin_file);
		header.check_validity ();

		var gameinfo = get_gameinfo ();
		var uid = new PlayStationUid (header);
		var title = new CompositeTitle ({
			new GameinfoDiscIdGameTitle (gameinfo, header.disc_id),
			new FilenameTitle (uri)
		});
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, SPECIFIC_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var input_capabilities = new GameinfoDiscIdInputCapabilities (gameinfo, header.disc_id);
		var core_source = new RetroCoreSource (PLATFORM, { SEARCHED_MIME_TYPE, SPECIFIC_MIME_TYPE });
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
