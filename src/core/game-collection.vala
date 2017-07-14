// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GameCollection : Object {
	private GenericSet<Game> games;
	private ListStore list_store;

	private UriSource[] sources;
	private UriGameFactory[] factories;

	private HashTable<string, Array<UriGameFactory>> factories_for_mime_type;
	private HashTable<string, Array<UriGameFactory>> factories_for_scheme;

	construct {
		games = new GenericSet<Game> (direct_hash, direct_equal);
		list_store = new ListStore (typeof (Game));
		factories_for_mime_type = new HashTable<string, Array<UriGameFactory>> (str_hash, str_equal);
		factories_for_scheme = new HashTable<string, Array<UriGameFactory>> (str_hash, str_equal);
	}

	public ListStore get_list_store () {
		return list_store;
	}

	public void add_source (UriSource source) {
		sources += source;
	}

	public void add_factory (UriGameFactory factory) {
		factories += factory;

		foreach (var mime_type in factory.get_mime_types ()) {
			if (!factories_for_mime_type.contains (mime_type))
				factories_for_mime_type[mime_type] = new Array<UriGameFactory> ();
			factories_for_mime_type[mime_type].append_val (factory);
		}

		foreach (var scheme in factory.get_schemes ()) {
			if (!factories_for_scheme.contains (scheme))
				factories_for_scheme[scheme] = new Array<UriGameFactory> ();
			factories_for_scheme[scheme].append_val (factory);
		}

		factory.game_added.connect ((game) => store_game (game));
	}

	public string[] get_accepted_mime_types () {
		return factories_for_mime_type.get_keys_as_array ();
	}

	public async void add_uri (Uri uri) {
		foreach (var factory in yield get_factories_for_uri (uri))
			yield factory.add_uri (uri);
	}

	public async Game? query_game_for_uri (Uri uri) {
		Game[] games = {};
		foreach (var factory in yield get_factories_for_uri (uri)) {
			var game = yield factory.query_game_for_uri (uri);
			if (game != null)
				games += game;
		}

		if (games.length != 1)
			return null;

		return games[0];
	}

	public async void search_games () {
		foreach (var source in sources)
			foreach (var uri in source)
				yield add_uri (uri);
	}

	public async void each_game (GameCallback callback) {
		foreach (var source in sources)
			foreach (var uri in source)
				yield add_uri (uri);

		foreach (var factory in factories)
			yield factory.foreach_game (callback);
	}

	private async UriGameFactory[] get_factories_for_uri (Uri uri) {
		Idle.add (get_factories_for_uri.callback);
		yield;

		UriGameFactory[] factories = {};

		string scheme;
		try {
			scheme = uri.get_scheme ();
		}
		catch (Error e) {
			debug (e.message);

			return factories;
		}

		if (scheme == "file") {
			try {
				var file = uri.to_file ();
				foreach (var factory in yield get_factories_for_file (file))
					factories += factory;
			}
			catch (Error e) {
				debug (e.message);
			}
		}
		// TODO Add support for URN.
		if (factories_for_scheme.contains (scheme))
			foreach (var factory in factories_for_scheme[scheme].data)
				factories += factory;

		return factories;
	}

	private async UriGameFactory[] get_factories_for_file (File file) throws Error {
		if (!file.query_exists ())
			return {};

		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();
		if (!factories_for_mime_type.contains (mime_type))
			return {};

		return factories_for_mime_type[mime_type].data;
	}

	private void store_game (Game game) {
		if (games.contains (game))
			return;

		list_store.append (game);
		games.add (game);
	}
}
