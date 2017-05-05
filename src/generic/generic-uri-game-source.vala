// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericUriGameSource : Object, GameSource {
	private UriSource[] sources;
	private UriGameFactory[] factories;

	private HashTable<string, Array<UriGameFactory>> factories_for_mime_type;

	construct {
		factories_for_mime_type = new HashTable<string, Array<UriGameFactory>> (str_hash, str_equal);
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
	}

	public async void add_uri (string uri) {
		foreach (var factory in yield get_factories_for_uri (uri))
			yield factory.add_uri (uri);
	}

	public async Game? query_game_for_uri (string uri) {
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

	public async void each_game (GameCallback callback) {
		foreach (var source in sources)
			foreach (var uri in source)
				yield add_uri (uri);

		foreach (var factory in factories)
			yield factory.foreach_game (callback);
	}

	private async UriGameFactory[] get_factories_for_uri (string uri) {
		Idle.add (get_factories_for_uri.callback);
		yield;

		UriGameFactory[] factories = {};

		if (uri.has_prefix ("file:")) {
			try {
				foreach (var factory in yield get_factories_for_file (uri))
					factories += factory;
			}
			catch (Error e) {
				debug (e.message);
			}
		}
		// TODO Add support for URN and other schemes.

		return factories;
	}

	private async UriGameFactory[] get_factories_for_file (string uri) throws Error {
		var file = File.new_for_uri (uri);
		if (!file.query_exists ())
			return {};

		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();
		if (!factories_for_mime_type.contains (mime_type))
			return {};

		return factories_for_mime_type[mime_type].data;
	}
}
