// This file is part of GNOME Games. License: GPL-3.0+.

private extern const string VERSION;

public class Games.Application : Gtk.Application {
	private ListStore collection;
	private ApplicationWindow window;
	private bool game_list_loaded;

	internal Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	construct {
		Environment.set_prgname ("gnome-games");
		Environment.set_application_name (_("Games"));
		Gtk.Window.set_default_icon_name ("org.gnome.Games");
		Environment.set_variable ("PULSE_PROP_media.role", "game", true);
		Environment.set_variable ("PULSE_PROP_application.icon_name", "org.gnome.Games", true);

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
		quit_action.activate.connect (quit_application);
		add_action (quit_action);
	}

	private void add_signal_handlers () {
		var interrupt_source = new Unix.SignalSource (ProcessSignal.INT);
		interrupt_source.set_callback (() => {
			quit_application ();

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

	public static string get_cache_dir () {
		var cache_dir = Environment.get_user_cache_dir ();

		return @"$cache_dir/gnome-games";
	}

	public static string get_config_dir () {
		var config_dir = Environment.get_user_config_dir ();

		return @"$config_dir/gnome-games";
	}

	public static string get_platforms_dir () {
		var config_dir = get_config_dir ();

		return @"$config_dir/platforms";
	}

	public static string get_covers_dir () {
		var cache_dir = get_cache_dir ();

		return @"$cache_dir/covers";
	}

	public static void try_make_dir (string path) {
		var file = File.new_for_path (path);
		try {
			if (!file.query_exists ())
				file.make_directory_with_parents ();
		}
		catch (Error e) {
			warning (@"$(e.message)\n");
		}
	}

	public static string get_medias_dir () {
		var data_dir = get_data_dir ();

		return @"$data_dir/medias";
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
			quit_application ();
		});
		window.show ();

		GLib.Timeout.add (500, show_loading_notification);
	}

	private bool show_loading_notification () {
		if (!game_list_loaded)
			window.loading_notification = true;

		return false;
	}

	internal async void load_game_list () {
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

		game_list_loaded = true;
		if (window != null)
			window.loading_notification = false;
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
		dialog.logo_icon_name = "org.gnome.Games";
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

	private void quit_application () {
		if (window != null && !window.quit_game ())
			return;

		quit ();
	}

	private static Gtk.CssProvider load_css (string css) {
		var provider = new Gtk.CssProvider ();
		try {
			var file = File.new_for_uri("resource:///org/gnome/Games/" + css);
			provider.load_from_file (file);
		} catch (GLib.Error e) {
			warning ("Loading CSS file “%s” failed: %s", css, e.message);
		}
		return provider;
	}

}
