// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-switch-item.ui")]
private class Games.PreferencesSwitchItem: Gtk.Box {
	[GtkChild]
	private Gtk.Label title_label;
	[GtkChild]
	private Gtk.Image select_image;

	public PreferencesSwitchItem (string name) {
		title_label.label = name;
	}

	public void switch_activate () {
		select_image.show ();
	}

	public void switch_deactivate () {
		select_image.hide ();
	}
}
