// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericGameUriAdapter : GameUriAdapter, Object {
	public delegate Game GameForUri (Uri uri) throws Error;

	private GameForUri callback;

	public GenericGameUriAdapter (owned GameForUri callback) {
		this.callback = (owned) callback;
	}

	public async Game game_for_uri (Uri uri) throws Error {
		Idle.add (this.game_for_uri.callback);
		yield;

		return callback (uri);
	}
}
