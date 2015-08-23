// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	public UiState ui_state { set; get; }

	[GtkChild]
	private ContentBox content_box;
	private Binding cb_ui_binding;

	[GtkChild]
	private HeaderBar header_bar;
	private Binding hb_ui_binding;

	private HashTable<Game, Runner> runners;

	public ApplicationWindow (ListModel collection) {
		content_box.collection = collection;
	}

	construct {
		runners = new HashTable<Game, Runner> (GLib.direct_hash, GLib.direct_equal);

		cb_ui_binding = content_box.bind_property ("ui-state",
		                                          this, "ui-state", BindingFlags.BIDIRECTIONAL);
		cb_ui_binding = header_bar.bind_property ("ui-state",
		                                          this, "ui-state", BindingFlags.BIDIRECTIONAL);
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		var runner = get_runner_for_game (game);
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

	private Runner get_runner_for_game (Game game) {
		if (runners.contains (game))
			return runners[game];

		var runner = game.get_runner ();
		runners[game] = runner;

		runner.stopped.connect (() => {
			if (runners.contains (game))
				runners.remove (game);
		});

		return runner;
	}
}
