// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/media-selector.ui")]
private class Games.MediaSelector : Gtk.Popover {
	private MediaSet _media_set;
	public MediaSet media_set {
		set {
			_media_set = value;

			remove_media ();
			update_media ();
		}
	}

	[GtkChild]
	private Gtk.ListBox list_box;

	private HashTable<Gtk.ListBoxRow, int> row_to_int;

	construct {
		row_to_int = new HashTable<Gtk.ListBoxRow, int> (direct_hash, direct_equal);
	}

	private void update_media () {
		var media_number = 0;

		if (_media_set == null)
			return;

		_media_set.foreach_media ((media) => {
			string media_name;
			if (media.title == null)
				media_name = _("Media %d").printf (media_number);
			else {
				try {
					media_name = media.title.get_title ();
				}
				catch (Error e) {
					warning (e.message);

					media_name = "";
				}
			}

			var row = new Gtk.ListBoxRow ();
			var label = new Gtk.Label (media_name);
			row.add (label);
			if (media_number == _media_set.selected_media_number)
				list_box.select_row (row);

			row_to_int.insert (row, media_number);

			add_row (row);

			media_number++;
		});
	}

	private void remove_media () {
		row_to_int.remove_all ();
		list_box.unselect_all ();
		list_box.foreach ((child) => child.destroy ());
	}

	private void add_row (Gtk.ListBoxRow row) {
		list_box.insert (row, -1);
		list_box.show_all ();
	}

	[GtkCallback]
	private void on_row_selected (Gtk.ListBoxRow? row) {
		if (row == null)
			return;

		if (!row_to_int.contains (row))
			return;

		var media_number = row_to_int[row];

		if (media_number == _media_set.selected_media_number)
			return;

		_media_set.selected_media_number = media_number;

		hide ();
	}
}
