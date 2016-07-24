// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/display-box.ui")]
private class Games.DisplayBox : Gtk.EventBox {
	public signal void game_activated (Game game);

	private Runner _runner;
	public Runner runner {
		set {
			_runner = value;
			remove_display ();

			if (runner == null)
				return;

			var display = runner.get_display ();
			set_display (display);
		}
		get { return _runner; }
	}

	private void set_display (Gtk.Widget display) {
		remove_display ();
		add (display);
		display.visible = true;
	}

	private void remove_display () {
		var child = get_child ();
		if (child != null)
			remove (get_child ());
	}
}
