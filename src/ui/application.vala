using Gtk;

public class Games.Application : Gtk.Application {
	public Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var window = new ApplicationWindow ();
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.load_game_list ();
		window.show_all ();
	}
}

