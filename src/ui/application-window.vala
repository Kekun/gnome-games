// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	[GtkChild]
	private CollectionIconView collection_icon_view;

	public ApplicationWindow (ListStore collection) {
		collection_icon_view.model = collection;
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		// TODO
	}

}
