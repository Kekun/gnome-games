// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	Gtk.ListStore games_list_store;

	[GtkChild]
	Gtk.IconView games_icon_view;

	public void load_game_list () {
		this.games_list_store = new Gtk.ListStore (2, typeof (string),
		                                              typeof (Gdk.Pixbuf));
		games_icon_view.set_model (games_list_store);
		games_icon_view.set_text_column (0);
		games_icon_view.set_pixbuf_column (1);

		var theme = Gtk.IconTheme.get_default ();
		var pixbuf = theme.load_icon ("input-gaming", 64, 0);

		var game_source = new Games.DummyGameSource ();
		game_source.each_game ((game) => {
			Gtk.TreeIter iter;
			games_list_store.append (out iter);
			games_list_store.set (iter, 0, game.name,
			                            1, pixbuf);
		});
	}
}
