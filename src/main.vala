using Gtk;

public class Games.GnomeGames: Gtk.Application {
	public GnomeGames() {
		Object(application_id: "org.gnome.Games",
		       flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate() {
		var window = new AppWindow();
		this.add_window(window);
		window.destroy.connect (() => {
			quit ();
		});
		window.loadGameList();
		window.show_all();
	}
}

int main (string[] args) {
    var app = new Games.GnomeGames();
    return app.run(args);
}

