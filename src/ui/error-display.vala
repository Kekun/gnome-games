// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/error-display.ui")]
private class Games.ErrorDisplay : Gtk.Box {
	[GtkChild]
	private Gtk.Label label;

	public void running_game_failed (Game game) {
		string message;
		if (game != null)
			message = _("Oops! Unable to run “%s”").printf (game.name);
		else
			message = _("Oops! Unable to run the game");

		label.label = @"<big><b>$message</b></big>";
	}
}
