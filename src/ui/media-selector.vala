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

			var checkmark_item = new CheckmarkItem (media_name);
			var is_current_media = (_media_set.selected_media_number == media_number);
			checkmark_item.checkmark_visible = is_current_media;
			list_box.add (checkmark_item);

			media_number++;
		});
	}

	private void remove_media () {
		list_box.foreach ((child) => child.destroy ());
	}

	[GtkCallback]
	private void on_row_activated (Gtk.ListBoxRow activated_row) {
		var media_number = activated_row.get_index ();
		_media_set.selected_media_number = media_number;

		var i = 0;
		var row = list_box.get_row_at_index (i);
		while (row != null) {
			var checkmark_item = (CheckmarkItem) row.get_child ();
			checkmark_item.checkmark_visible = (i == media_number);

			row = list_box.get_row_at_index (++i);
		}

		popdown ();
	}
}
