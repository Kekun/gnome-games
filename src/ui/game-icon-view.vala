// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/game-icon-view.ui")]
private class Games.GameIconView : Gtk.Box {
	private Game _game;
	public Game game {
		get { return _game; }
		set {
			if (value == game)
				return;

			_game = value;

			thumbnail.icon = game.get_icon ();
			thumbnail.cover = game.get_cover ();
			title.label = game.name;

			queue_draw ();
		}
	}

	[GtkChild]
	private GameThumbnail thumbnail;
	[GtkChild]
	private Gtk.Label title;

	public GameIconView (Game game) {
		this.game = game;
	}
}
