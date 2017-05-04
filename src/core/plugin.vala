// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.Plugin : Object {
	public virtual GameSource? get_game_source () throws Error {
		return null;
	}

	public virtual string[] get_mime_types () {
		return {};
	}
}
