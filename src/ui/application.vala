// This file is part of GNOME Games. License: GPLv3

using Gtk;

public class Games.Application : Gtk.Application {
	public Application () {
		Object (application_id: "org.gnome.Games",
		        flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

		var screen = Gdk.Screen.get_default ();
		var provider = load_css ("gtk-style.css");
		Gtk.StyleContext.add_provider_for_screen (screen, provider, 600);

		var window = new ApplicationWindow ();
		this.add_window (window);
		window.destroy.connect (() => {
			quit ();
		});
		window.load_game_list ();
		window.show_all ();
	}

	private static Gtk.CssProvider load_css (string css) {
		var provider = new CssProvider ();
		try {
			var file = File.new_for_uri("resource:///org/gnome/Games/" + css);
			provider.load_from_file (file);
		} catch (GLib.Error e) {
			warning ("Loading CSS file '%s'failed: %s", css, e.message);
		}
		return provider;
	}

}

