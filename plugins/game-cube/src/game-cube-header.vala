// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: http://www.gc-forever.com/yagcd/chap13.html
private class Games.GameCubeHeader: Object {
	private const size_t MAGIC_OFFSET = 0x1c;
	private const string MAGIC_VALUE = "\xc2\x33\x9f\x3d";

	private const size_t ID_OFFSET = 0;
	private const size_t ID_SIZE = 6;

	private File file;

	public GameCubeHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws Error {
		var stream = new StringInputStream (file);
		if (!stream.has_string (MAGIC_OFFSET, MAGIC_VALUE))
			throw new GameCubeError.INVALID_HEADER (_("The file doesn’t have a Game Cube header."));
	}

	public string get_game_id () throws Error {
		var stream = new StringInputStream (file);

		return stream.read_string_for_size (ID_OFFSET, ID_SIZE);
	}
}

errordomain Games.GameCubeError {
	INVALID_HEADER,
}
