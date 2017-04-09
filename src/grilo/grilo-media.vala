// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GriloMedia : Object {
	private static Grl.Registry registry;

	public signal void resolved ();

	private Title title;
	private string mime_type;
	private bool resolving;

	private Grl.Media? media;

	public GriloMedia (Title title, string mime_type) {
		this.title = title;
		this.mime_type = mime_type;
		resolving = false;
	}

	private static Grl.Registry get_registry () throws Error {
		if (registry != null)
			return registry;

		registry = Grl.Registry.get_default ();
		registry.load_all_plugins(true);

		return registry;
	}

	public void try_resolve_media () {
		try {
			resolve_media ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	internal Grl.Media? get_media () {
		return media;
	}

	private void resolve_media () throws Error {
		if (resolving)
			return;

		resolving = true;

		var registry = get_registry ();
		var source = registry.lookup_source ("grl-thegamesdb");
		if (source == null)
			return;

		var base_media = new Grl.Media ();
		var title_string = title.get_title ();
		base_media.set_title (title_string);
		base_media.set_mime (mime_type);

		var keys = Grl.MetadataKey.list_new (Grl.MetadataKey.THUMBNAIL,
		                                     null);

		var options = new Grl.OperationOptions (null);
		options.set_resolution_flags (Grl.ResolutionFlags.FULL);

		source.do_resolve (base_media, keys, options, on_media_resolved);
	}

	private void on_media_resolved (Grl.Source source, uint operation_id, owned Grl.Media media, GLib.Error? error) {
		this.media = media;
		resolved ();
	}
}
