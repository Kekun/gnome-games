// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.LoveIcon : Object, Icon {
	private static GLib.Icon? love_icon;

	private LovePackage package;
	private bool already_parsed;
	private Gdk.Pixbuf pixbuf;

	public LoveIcon (LovePackage package) {
		this.package = package;
		already_parsed = false;
	}

	static construct {
		try {
			love_icon = GLib.Icon.new_for_string ("love");
		}
		catch (Error e) {
			warning ("%s\n", e.message);
		}
	}

	public GLib.Icon? get_icon () {
		if (pixbuf != null)
			return pixbuf;

		if (already_parsed)
			return love_icon;

		already_parsed = true;

		var icon_path = package.get_config ("icon");
		if (icon_path == null)
			return null;

		var stream = package.get_file_input_stream (icon_path);
		if (stream == null)
			return null;

		try {
			pixbuf = new Gdk.Pixbuf.from_stream (stream);
		}
		catch (Error e) {
			warning (e.message);
		}
		if (pixbuf != null)
			return pixbuf;

		return love_icon;
	}
}
