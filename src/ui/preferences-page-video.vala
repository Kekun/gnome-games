// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-page-video.ui")]
private class Games.PreferencesPageVideo: Gtk.Bin, PreferencesPage {
	public string title {
		get { return _("Video"); }
	}

	private string _filter_active;
	public string filter_active {
		set {
			for (var i = 0; i < filter_names.length; i++) {
				var row_item = filter_list_box.get_row_at_index (i);
				var switch_item = (PreferencesSwitchItem) row_item.get_child ();
				if (value == filter_names[i])
					switch_item.switch_activate ();
				else
					switch_item.switch_deactivate ();
			}
			_filter_active = value;
		}

		get {
			return _filter_active;
		}
	}

	// same as video-filters in gschema
	private string[] filter_display_names = { _("Smooth"), _("Sharp") };
	private string[] filter_names = { "smooth", "sharp" };
	[GtkChild]
	private Gtk.ListBox filter_list_box;
	private Settings settings;

	construct {
		foreach (var filter_display_name in filter_display_names) {
			var switch_item = new PreferencesSwitchItem (filter_display_name);
			filter_list_box.add (switch_item);
		}
		settings = new Settings ("org.gnome.Games");
		settings.bind ("video-filter", this, "filter-active",
		               SettingsBindFlags.DEFAULT);
	}

	[GtkCallback]
	private void filter_list_box_row_activated (Gtk.ListBoxRow row_item) {
		filter_active = filter_names[row_item.get_index ()];
	}
}
