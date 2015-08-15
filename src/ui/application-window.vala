// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	private ListStore collection;

	[GtkChild]
	private CollectionIconView collection_icon_view;

	public void load_game_list () {
		this.collection = new ListStore (typeof (Game));

		var dummy_source = new Games.DummyGameSource ();
		dummy_source.each_game ((game) => {
			collection.append (game);
		});

		collection_icon_view.model = collection;
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		// TODO
	}

}
