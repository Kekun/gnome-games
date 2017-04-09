// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/display-header-bar.ui")]
private class Games.DisplayHeaderBar : Gtk.HeaderBar {
	public signal void back ();

	[GtkChild]
	private MediaMenuButton media_button;

	public string game_title {
		set { title = value; }
	}

	public bool can_fullscreen { set; get; }
	public bool is_fullscreen { set; get; }

	public MediaSet? media_set {
		set {
			media_button.media_set = value;
			media_selector.media_set = value;
		}
	}

	private MediaSelector media_selector;

	[GtkChild]
	private Gtk.Button fullscreen;

	[GtkChild]
	private Gtk.Button restore;

	private Settings settings;

	construct {
		settings = new Settings ("org.gnome.Games");

		media_selector = new MediaSelector ();
		media_selector.set_relative_to (media_button);
		media_button.set_popover (media_selector);
	}

	[GtkCallback]
	private void on_fullscreen_changed () {
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
		settings.set_boolean ("fullscreen", true);
	}

	[GtkCallback]
	private void on_restore_clicked () {
		is_fullscreen = false;
		settings.set_boolean ("fullscreen", false);
	}
}
