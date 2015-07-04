using Gtk;

public class GnomeGames: Gtk.Application {
	public GnomeGames() {
		Object(application_id: "org.gnome.Games",
		       flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate() {
		var window = new AppWindow();
		this.add_window(window);
		window.show_all();
	}
}

int main (string[] args) {
    var app = new GnomeGames();
    return app.run(args);
}

