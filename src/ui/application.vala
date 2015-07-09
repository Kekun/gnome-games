using Gtk;

public class Games.Application : Gtk.Application {
	public Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var tracker = Tracker.Sparql.Connection.@get ();
		var game_source = new Games.DesktopGameSource (tracker);

		var window = new AppWindow ();
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.load_games (game_source);
		window.show_all ();
	}
}

