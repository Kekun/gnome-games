// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/resume-failed-dialog.ui")]
private class Games.ResumeFailedDialog : Gtk.Dialog {
	construct {
		// GtkBuilder can't set construct properties so we have to set 'use-header-bar' manually.
		use_header_bar = 1;
	}
}
