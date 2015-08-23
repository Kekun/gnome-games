// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	public UiState ui_state { set; get; }

	[GtkChild]
	private ContentBox content_box;
	private Binding cb_ui_binding;

	public ApplicationWindow (ListModel collection) {
		content_box.collection = collection;
	}

	construct {
		cb_ui_binding = content_box.bind_property ("ui-state",
		                                          this, "ui-state", BindingFlags.BIDIRECTIONAL);
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		var runner = game.get_runner ();
		try {
			runner.run ();
		}
		catch (RunError e) {
			warning (@"$(e.message)\n");

			return;
		}

		content_box.runner = runner;

		ui_state = UiState.DISPLAY;
	}
}
