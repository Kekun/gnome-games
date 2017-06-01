// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.UriGameFactory : Object {
	public signal void game_added (Game game);

	public virtual string[] get_mime_types () {
		return {};
	}

	public virtual string[] get_schemes () {
		return {};
	}

	public abstract async void add_uri (Uri uri);
	public abstract async Game? query_game_for_uri (Uri uri);
	public abstract async void foreach_game (Games.GameCallback game_callback);
}
