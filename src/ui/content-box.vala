// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/content-box.ui")]
private class Games.ContentBox : Gtk.Box {
	public signal void game_activated (Game game);

	public bool search_mode { set; get; }

	private UiState _ui_state;
	public UiState ui_state {
		set {
			if (value == ui_state)
				return;

			_ui_state = value;

			switch (ui_state) {
			case UiState.COLLECTION:
				content_stack.set_visible_child (collection_icon_view);
				if (runner != null) {
					runner.pause ();
					runner = null;
				}

				break;
			case UiState.DISPLAY:
				content_stack.set_visible_child (display_box);

				break;
			}
		}
		get { return _ui_state; }
	}

	public ListModel collection {
		set { collection_icon_view.model = value; }
		get { return collection_icon_view.model; }
	}

	[GtkChild]
	private SearchBar search_bar;
	private Binding sb_search_binding;

	[GtkChild]
	private Gtk.Box info_box;
	[GtkChild]
	private Gtk.Stack content_stack;
	[GtkChild]
	private CollectionIconView collection_icon_view;
	[GtkChild]
	private Gtk.EventBox display_box;

	private Runner _runner;
	public Runner runner {
		set {
			if (runner != null)
				runner.disconnect (runner_stopped_id);

			_runner = value;
			remove_display ();

			if (runner == null)
				return;

			runner_stopped_id = runner.stopped.connect (on_runner_stopped);

			var display = runner.get_display ();
			set_display (display);
		}
		private get { return _runner; }
	}
	private ulong runner_stopped_id;

	public ContentBox (ListStore collection) {
		collection_icon_view.model = collection;
	}

	construct {
		sb_search_binding = search_bar.bind_property ("search-mode-enabled",
		                                              this, "search-mode", BindingFlags.BIDIRECTIONAL);
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
		collection_icon_view.filtering_text = search_bar.text;
	}

	public bool search_bar_handle_event (Gdk.Event event) {
		return search_bar.handle_event (event);
	}

	private void set_display (Gtk.Widget display) {
		remove_display ();
		display_box.add (display);
		display.visible = true;
	}

	private void remove_display () {
		var child = display_box.get_child ();
		if (child != null)
			display_box.remove (display_box.get_child ());
	}

	private void on_runner_stopped () {
		runner = null;
		ui_state = UiState.COLLECTION;
	}
}
