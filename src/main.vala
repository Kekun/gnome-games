using Gtk;

public class Games.GnomeGames : Gtk.Application {
	public GnomeGames () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var window = new AppWindow ();
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.load_game_list ();
		window.show_all ();
	}
}

int main (string[] args) {
	var app = new Games.GnomeGames ();
	return app.run (args);
}
