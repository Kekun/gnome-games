// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamIcon : Object, Icon {
	private static GLib.Icon? steam_icon;

	private string game_id;
	private GLib.Icon? icon;
	private bool searched;

	static construct {
		try {
			steam_icon = GLib.Icon.new_for_string ("steam");
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

	public SteamIcon (string game_id) {
		this.game_id = game_id;

		searched = false;
	}

	public GLib.Icon? get_icon () {
		if (searched)
			return icon ?? steam_icon;

		searched = true;

		try {
			var icon_name = "steam_icon_" + game_id;
			var theme = Gtk.IconTheme.get_default ();
			if (theme.has_icon (icon_name))
				icon = GLib.Icon.new_for_string (icon_name);
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}

		return icon ?? steam_icon;
	}
}
