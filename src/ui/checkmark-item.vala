// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/checkmark-item.ui")]
private class Games.CheckmarkItem: Gtk.Box {
	[GtkChild]
	private Gtk.Label title_label;
	[GtkChild]
	private Gtk.Image checkmark_image;

	public bool checkmark_visible { set; get; }
	private Binding checkmark_visible_binding;

	public CheckmarkItem (string name) {
		title_label.label = name;
	}

	construct {
		checkmark_visible_binding = bind_property ("checkmark-visible", checkmark_image, "visible",
		                                           BindingFlags.DEFAULT);
	}
}
