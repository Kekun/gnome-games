// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-window.ui")]
private class Games.PreferencesWindow : Gtk.Window {
	[GtkChild]
	private Gtk.HeaderBar right_header_bar;
	[GtkChild]
	private Gtk.Stack stack;

	public PreferencesWindow () {
		stack.foreach ((child) => {
			var page = child as PreferencesPage;
			page.notify["title"].connect (update_title);
		});
		stack.notify["visible-child-name"].connect (update_title);
		update_title ();
	}

	private void update_title () {
		var page = (PreferencesPage) stack.get_visible_child ();
		right_header_bar.title = (page == null) ? "" : page.title;
	}
}
