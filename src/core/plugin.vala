// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.Plugin : Object {
	public virtual string[] get_mime_types () {
		return {};
	}

	public virtual UriSource[] get_uri_sources () {
		return {};
	}

	public virtual UriGameFactory[] get_uri_game_factories () {
		return {};
	}
}
