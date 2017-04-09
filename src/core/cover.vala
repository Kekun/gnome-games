// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.Cover : Object {
	public signal void changed ();

	public abstract GLib.Icon? get_cover ();
}
