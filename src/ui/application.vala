// This file is part of GNOME Games. License: GPLv3

private extern const string VERSION;

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

	private Gtk.Window window;

	public Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	construct {
		add_actions ();
		add_signal_handlers ();
	}

	private void add_actions () {
		SimpleAction preferences_action = new SimpleAction ("preferences", null);
		preferences_action.activate.connect (preferences);
		add_action (preferences_action);

		SimpleAction about_action = new SimpleAction ("about", null);
		about_action.activate.connect (about);
		add_action (about_action);

		SimpleAction quit_action = new SimpleAction ("quit", null);
		quit_action.activate.connect (quit);
		add_action (quit_action);
	}

	private void add_signal_handlers () {
		var interrupt_source = new Unix.SignalSource (ProcessSignal.INT);
		interrupt_source.set_callback (() => {
			quit ();

			return Source.CONTINUE;
		});
		interrupt_source.attach (MainContext.@default ());
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

		window = new ApplicationWindow (collection);
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.show ();
	}

	public async void load_game_list () {
		GameSource[] sources = {};

		var register = PluginRegister.get_register ();
		register.foreach_plugin_registrar ((plugin_registrar) => {
			try {
				var plugin = plugin_registrar.get_plugin ();
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

		yield tracker_source.each_game (add_game);
	}

	private void add_game (Game game) {
		collection.append (game);
	}

	private void preferences () {
		new PreferencesWindow ();
	}

	private void about () {
		Gtk.AboutDialog dialog = new Gtk.AboutDialog ();
		dialog.set_destroy_with_parent (true);
		dialog.set_transient_for (window);
		dialog.set_modal (true);

		dialog.program_name = _("GNOME Games");
		dialog.logo_icon_name = "gnome-games";
		dialog.comments = _("A video game player for GNOME");
		dialog.version = VERSION;

		dialog.website = "https://wiki.gnome.org/Apps/Games";
		dialog.website_label = _("Learn more about GNOME Games");

		dialog.license_type = Gtk.License.GPL_3_0;

		dialog.authors = Credits.AUTHORS;
		dialog.artists = Credits.ARTISTS;
		dialog.documenters = Credits.DOCUMENTERS;
		dialog.translator_credits = _("translator-credits");

		dialog.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT)
				dialog.hide_on_delete ();
		});

		dialog.present ();
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

