// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/error-display.ui")]
private class Games.ErrorDisplay : Gtk.Box {
	[GtkChild]
	private Gtk.Label primary_label;
	[GtkChild]
	private Gtk.Label secondary_label;

	public void running_game_failed (Game game, string message) {
		string title;
		if (game != null)
			title = _("Oops! Unable to run “%s”").printf (game.name);
		else
			title = _("Oops! Unable to run the game");

		set_labels (title, message);
	}

	private void set_labels (string primary, string secondary) {
		primary_label.label = @"<big><b>$(Markup.escape_text (primary))</b></big>";
		secondary_label.label = Markup.escape_text (secondary);
	}
}
