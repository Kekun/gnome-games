// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/header-bar.ui")]
private class Games.HeaderBar : Gtk.Stack {
	public signal void display_back ();

	private UiState _ui_state;
	public UiState ui_state {
		set {
			if (value == ui_state)
				return;

			_ui_state = value;

			switch (ui_state) {
			case UiState.COLLECTION:
				set_visible_child (collection_header);

				break;
			case UiState.DISPLAY:
				set_visible_child (display_header);

				break;
			}
		}
		get { return _ui_state; }
	}

	public bool search_mode { set; get; }

	public string game_title {
		set { display_header.title = value; }
	}

	[GtkChild]
	private Gtk.HeaderBar collection_header;

	[GtkChild]
	private Gtk.ToggleButton collection_search;
	private Binding sb_active_binding;

	[GtkChild]
	private Gtk.HeaderBar display_header;

	construct {
		sb_active_binding = collection_search.bind_property ("active",
		                                                     this, "search-mode", BindingFlags.BIDIRECTIONAL);
	}

	[GtkCallback]
	private void on_display_back_clicked () {
		display_back ();
	}
}
