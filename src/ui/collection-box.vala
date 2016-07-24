// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-box.ui")]
private class Games.CollectionBox : Gtk.Box {
	public signal void game_activated (Game game);

	public ListModel collection { construct set; get; }
	public bool search_mode { set; get; }

	[GtkChild]
	private SearchBar search_bar;
	[GtkChild]
	private Gtk.Box info_box;
	[GtkChild]
	private CollectionIconView icon_view;

	private Binding collection_binding;
	private Binding search_binding;

	public CollectionBox (ListStore collection) {
		Object (collection: collection);
	}

	construct {
		collection_binding = bind_property ("collection", icon_view, "model",
		                                    BindingFlags.BIDIRECTIONAL);
		search_binding = bind_property ("search-mode", search_bar, "search-mode-enabled",
		                                BindingFlags.BIDIRECTIONAL);
	}

	public void display_error (string message) {
		var error = new ErrorInfoBar ();
		error.message = message;
		info_box.pack_start (error, false, false);

		error.response.connect (on_info_bar_response);
		error.close.connect (on_info_bar_close);
	}

	private void on_info_bar_response (Gtk.InfoBar info_bar, int response_id) {
		info_box.remove (info_bar);
	}

	private void on_info_bar_close (Gtk.InfoBar info_bar) {
		info_box.remove (info_bar);
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		game_activated (game);
	}

	[GtkCallback]
	private void on_search_text_notify () {
		icon_view.filtering_text = search_bar.text;
	}

	public bool search_bar_handle_event (Gdk.Event event) {
		return search_bar.handle_event (event);
	}
}
