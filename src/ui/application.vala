// This file is part of GNOME Games. License: GPLv3

private class Games.Application : Gtk.Application {
	private ListStore collection;

	private Tracker.Sparql.Connection? _connection;
	private Tracker.Sparql.Connection? connection {
		get {
			if (_connection != null)
				return _connection;

			try {
				_connection = Tracker.Sparql.Connection.@get ();
			}
			catch (Error e) {
				warning ("Error: %s\n", e.message);
			}

			return _connection;
		}
	}

	public Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	public static string get_data_dir () {
		var data_dir = Environment.get_user_data_dir ();

		return @"$data_dir/gnome-games";
	}

	public static string get_saves_dir () {
		var data_dir = get_data_dir ();

		return @"$data_dir/saves";
	}

	public static string get_snapshots_dir () {
		var data_dir = get_data_dir ();

		return @"$data_dir/snapshots";
	}

	protected override void activate () {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var screen = Gdk.Screen.get_default ();
		var provider = load_css ("gtk-style.css");
		Gtk.StyleContext.add_provider_for_screen (screen, provider, 600);

		collection = new ListStore (typeof (Game));
		load_game_list.begin ();

		var window = new ApplicationWindow (collection);
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.show ();
	}

	public async void load_game_list () {
		GameSource[] sources = {};

		var register = new PluginRegister ();
		register.foreach_plugin ((plugin) => {
			try {
				var source = plugin.get_game_source ();
				if (source != null)
					sources += source;
			}
			catch (Error e) {
				debug ("Error: %s", e.message);
			}
		});

		foreach (var source in sources)
			yield source.each_game (add_game);

		if (connection == null)
			return;

		var tracker_source = new TrackerGameSource (connection);

		tracker_source.add_query (new AmigaTrackerQuery ());
		tracker_source.add_query (new DoomTrackerQuery ());
		tracker_source.add_query (new DreamcastTrackerQuery ());
		tracker_source.add_query (new LoveTrackerQuery ());

		yield tracker_source.each_game (add_game);
	}

	private void add_game (Game game) {
		collection.append (game);
	}

	private static Gtk.CssProvider load_css (string css) {
		var provider = new Gtk.CssProvider ();
		try {
			var file = File.new_for_uri("resource:///org/gnome/Games/" + css);
			provider.load_from_file (file);
		} catch (GLib.Error e) {
			warning ("Loading CSS file '%s'failed: %s", css, e.message);
		}
		return provider;
	}

}

