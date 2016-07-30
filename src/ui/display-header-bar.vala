// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/display-header-bar.ui")]
private class Games.DisplayHeaderBar : Gtk.HeaderBar {
	public signal void back ();

	public string game_title {
		set { title = value; }
	}

	public bool can_fullscreen { set; get; }
	public bool is_fullscreen { set; get; }

	[GtkChild]
	private Gtk.Button fullscreen;

	[GtkChild]
	private Gtk.Button restore;

	[GtkCallback]
	private void on_fullscrren_changed () {
		fullscreen.visible = can_fullscreen && !is_fullscreen;
		restore.visible = can_fullscreen && is_fullscreen;
	}

	[GtkCallback]
	private void on_back_clicked () {
		back ();
	}

	[GtkCallback]
	private void on_fullscreen_clicked () {
		is_fullscreen = true;
	}

	[GtkCallback]
	private void on_restore_clicked () {
		is_fullscreen = false;
	}
}
