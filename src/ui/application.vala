// This file is part of GNOME Games. License: GPLv3

public class Games.Application : Gtk.Application {
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
		if (connection == null)
			return;

		var tracker_source = new TrackerGameSource (connection);

		tracker_source.add_query (new DesktopTrackerQuery ());
		tracker_source.add_query (new GameBoyTrackerQuery ());
		tracker_source.add_query (new GameBoyAdvanceTrackerQuery ());
		tracker_source.add_query (new GameCubeTrackerQuery ());
		tracker_source.add_query (new LoveTrackerQuery ());
		tracker_source.add_query (new MasterSystemTrackerQuery ());
		tracker_source.add_query (new MegaDriveTrackerQuery ());
		tracker_source.add_query (new NesTrackerQuery ());
		tracker_source.add_query (new Nintendo64TrackerQuery ());
		tracker_source.add_query (new PcEngineTrackerQuery ());
		tracker_source.add_query (new SnesTrackerQuery ());
		tracker_source.add_query (new WiiTrackerQuery ());
		tracker_source.add_query (new WiiWareTrackerQuery ());

		yield tracker_source.each_game (add_game);

		SteamGameSource steam_source = null;
		try {
			steam_source = new SteamGameSource ();
		}
		catch (Error e) {
			warning ("Can't list Steam games: %s\n'", e.message);
		}

		if (steam_source != null)
			yield steam_source.each_game (add_game);
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

