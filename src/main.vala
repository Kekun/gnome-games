using Gtk;

public void on_delete_event(ApplicationWindow window) {
	Gtk.main_quit();
}

namespace GnomeGames {
	public class Application: Gtk.Application {
		public Application() {
			Object(application_id: "org.gnome.Games",
			       flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate() {
			var builder = new Builder ();
			try {
			    builder.add_from_file("data/ui/app-window.ui");
			}
			catch(Error e) {
			    error ("Error loading UI: %s", e.message);
			}
			var window = builder.get_object("applicationwindow1") as ApplicationWindow;
			this.add_window(window);
			window.show_all();
		}
	}
}

int main (string[] args) {
    var app = new GnomeGames.Application();
    return app.run(args);
}

