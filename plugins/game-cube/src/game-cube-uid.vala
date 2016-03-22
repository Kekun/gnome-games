// This file is part of GNOME Games. License: GPLv3

private class Games.GameCubeUid: Object, Uid {
	private GameCubeHeader header;
	private string uid;

	public GameCubeUid (GameCubeHeader header) {
		this.header = header;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var game_id = header.get_game_id ();
		uid = @"game-cube-$game_id".down ();

		return uid;
	}
}
