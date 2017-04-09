// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-header-bar.ui")]
private class Games.CollectionHeaderBar : Gtk.HeaderBar {
	public bool search_mode { set; get; }

	[GtkChild]
	private Gtk.ToggleButton search;
	private Binding search_binding;

	construct {
		search_binding = bind_property ("search-mode", search, "active",
		                                BindingFlags.BIDIRECTIONAL);
	}
}
