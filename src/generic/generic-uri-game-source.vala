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

	public async void each_game (GameCallback callback) {
		foreach (var source in sources)
			foreach (var uri in source)
				yield add_uri (uri);

		foreach (var factory in factories)
			yield factory.foreach_game (callback);
	}

	private async void add_uri (string uri) {
		Idle.add (add_uri.callback);
		yield;

		if (uri.has_prefix ("file:")) {
			try {
				yield add_file (uri);
			}
			catch (Error e) {
				debug (e.message);
			}

			return;
		}
		// TODO Add support for URN and other schemes.
	}

	private async void add_file (string uri) throws Error {
		var file = File.new_for_uri (uri);
		if (!file.query_exists ())
			return;

		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();
		if (!factories_for_mime_type.contains (mime_type))
			return;

		foreach (var factory in factories_for_mime_type[mime_type].data)
			yield factory.add_uri (uri);
	}
}
