// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/collection-icon-view.ui")]
private class Games.CollectionIconView : Gtk.ScrolledWindow {
	public signal void game_activated (Game game);

	private ListModel _model;
	public ListModel model {
		get { return _model; }
		set {
			_model = value;

			clear_content ();
			for (int i = 0 ; i < model.get_n_items () ; i++) {
				var game = model.get_item (i) as Game;
				var game_view = new GameIconView (game);
				var child = new Gtk.FlowBoxChild ();

				game_view.visible = true;
				child.visible = true;

				child.add (game_view);
				flow_box.add (child);
			}
		}
	}

	[GtkChild]
	private Gtk.FlowBox flow_box;

	construct {
		flow_box.max_children_per_line = uint.MAX;
	}

	[GtkCallback]
	private void on_child_activated (Gtk.FlowBoxChild child) {
		if (child.get_child () is GameIconView)
			on_game_view_activated (child.get_child () as GameIconView);
	}

	private void on_game_view_activated (GameIconView game_view) {
		game_activated (game_view.game);
	}

	private void clear_content () {
		flow_box.forall ((child) => { flow_box.remove (child); });
	}
}
