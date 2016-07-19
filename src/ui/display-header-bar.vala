// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/display-header-bar.ui")]
private class Games.DisplayHeaderBar : Gtk.HeaderBar {
	public signal void back ();

	public string game_title {
		set { title = value; }
	}

	[GtkCallback]
	private void on_back_clicked () {
		back ();
	}
}
