// This file is part of GNOME Games. License: GPLv3

public interface Games.GameUriAdapter : Object {
	public abstract async Game game_for_uri (string uri) throws Error;
}
