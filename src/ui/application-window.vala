// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	public UiState ui_state { set; get; }

	[GtkChild]
	private Gtk.Stack stack;
	[GtkChild]
	private CollectionIconView collection_icon_view;

	private Runner runner;

	public ApplicationWindow (ListStore collection) {
		collection_icon_view.model = collection;
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		runner = game.get_runner ();

		var display = runner.get_display ();
		if (display != null) {
			display.visible = true;
			stack.add (display);
			stack.set_visible_child (display);
		}

		try {
			runner.run ();
		}
		catch (RunError e) {
			warning (@"$(e.message)\n");
		}
	}

}
