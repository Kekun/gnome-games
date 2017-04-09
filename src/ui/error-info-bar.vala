// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/error-info-bar.ui")]
private class Games.ErrorInfoBar : Gtk.InfoBar {
	[GtkChild]
	private Gtk.Label label;

	construct {
		show_close_button = true; // FIXME: Why doesn't this work from template?
		message_type = Gtk.MessageType.ERROR; // FIXME: Why doesn't this work from template?
	}

	public string message {
		set { label.label = value; }
	}
}
