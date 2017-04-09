// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.NintendoDsIcon : Object, Icon {
	private string uri;
	private bool extracted;
	private Gdk.Pixbuf pixbuf;

	public NintendoDsIcon (string uri) {
		this.uri = uri;
		extracted = false;
	}

	private static extern Gdk.Pixbuf extract (string uri) throws Error;

	public GLib.Icon? get_icon () {
		if (extracted)
			return pixbuf;

		extracted = true;

		try {
			pixbuf = extract (uri);
		}
		catch (Error e) {
			warning (e.message);
		}

		return pixbuf;
	}
}
