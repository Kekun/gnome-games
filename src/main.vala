using Gtk;

public class Games.GnomeGames: Gtk.Application {
	public GnomeGames() {
		Object(application_id: "org.gnome.Games",
		       flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate() {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var game_source = new Games.DummyGameSource();

		var window = new AppWindow();
		this.add_window(window);
		window.destroy.connect (() => {
			quit ();
		});
		window.loadGameList(game_source);
		window.show_all();
	}
}

int main (string[] args) {
    var app = new Games.GnomeGames();
    return app.run(args);
}

