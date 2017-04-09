// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-box.ui")]
private class Games.CollectionBox : Gtk.Box {
	public signal void game_activated (Game game);

	public ListModel collection { construct set; get; }
	public bool search_mode { set; get; }
	public bool loading_notification { set; get; }

	[GtkChild]
	private SearchBar search_bar;
	[GtkChild]
	private Gtk.Revealer loading_notification_revealer;
	[GtkChild]
	private CollectionIconView icon_view;

	private Binding collection_binding;
	private Binding search_binding;
	private Binding loading_notification_binding;

	public CollectionBox (ListStore collection) {
		Object (collection: collection);
	}

	construct {
		collection_binding = bind_property ("collection", icon_view, "model",
		                                    BindingFlags.BIDIRECTIONAL);
		search_binding = bind_property ("search-mode", search_bar, "search-mode-enabled",
		                                BindingFlags.BIDIRECTIONAL);
		loading_notification_binding = bind_property ("loading-notification", loading_notification_revealer, "reveal-child",
		                                              BindingFlags.DEFAULT);
	}

	[GtkCallback]
	private void on_loading_notification_closed () {
		loading_notification_revealer.set_reveal_child (false);
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
