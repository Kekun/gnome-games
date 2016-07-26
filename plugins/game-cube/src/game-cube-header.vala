// This file is part of GNOME Games. License: GPLv3

// Documentation: http://www.gc-forever.com/yagcd/chap13.html
private class Games.GameCubeHeader: Object {
	private const size_t MAGIC_OFFSET = 0x1c;
	private const string MAGIC_VALUE = "\xc2\x33\x9f\x3d";

	private File file;

	public GameCubeHeader (File file) {
		this.file = file;
	}

	public void check_validity () throws GameCubeError {
		var stream = get_stream ();
		try {
			stream.seek (MAGIC_OFFSET, SeekType.SET);
		}
		catch (Error e) {
			throw new GameCubeError.INVALID_SIZE (_("Invalid Game Cube header size: %s"), e.message);
		}

		var buffer = new uint8[MAGIC_VALUE.length];
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new GameCubeError.INVALID_SIZE (e.message);
		}

		var magic = (string) buffer;
		if (magic != MAGIC_VALUE)
			throw new GameCubeError.INVALID_HEADER (_("The file doesn't have a Game Cube header."));
	}

	public string get_game_id () throws GameCubeError {
		uint8 buffer[6];

		var stream = get_stream ();
		try {
			stream.read (buffer);
		}
		catch (Error e) {
			throw new GameCubeError.INVALID_HEADER (_("The file doesn't have a Game Cube header."));
		}

		return (string) buffer;
	}

	private FileInputStream get_stream () throws GameCubeError {
		try {
			return file.read ();
		}
		catch (Error e) {
			throw new GameCubeError.CANT_READ_FILE (_("Couldn't read file: %s"), e.message);
		}
	}
}

errordomain Games.GameCubeError {
	CANT_READ_FILE,
	INVALID_SIZE,
	INVALID_HEADER,
}
