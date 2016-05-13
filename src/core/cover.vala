// This file is part of GNOME Games. License: GPLv3

public interface Games.Cover : Object {
	public signal void changed ();

	public abstract GLib.Icon? get_cover ();
}
