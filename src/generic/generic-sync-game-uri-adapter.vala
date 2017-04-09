// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericSyncGameUriAdapter : GameUriAdapter, Object {
	public delegate Game GameForUri (string uri) throws Error;

	private GameForUri callback;

	public GenericSyncGameUriAdapter (owned GameForUri callback) {
		this.callback = (owned) callback;
	}

	public async Game game_for_uri (string uri) throws Error {
		return callback (uri);
	}
}
