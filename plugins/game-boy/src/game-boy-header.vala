// This file is part of GNOME Games. License: GPL-3.0+.

// Documentation: http://gbdev.gg8.se/wiki/articles/The_Cartridge_Header
private class Games.GameBoyHeader : Object {
	private const size_t COLOR_TYPE_OFFSET = 0x143;
	private const uint8 COLOR_ENABLED_VALUE = 0x80;
	private const uint8 COLOR_ONLY_VALUE = 0xC0;

	private const size_t SUPER_TYPE_OFFSET = 0x146;
	private const uint8 SUPER_DISABLED_VALUE = 0x00;
	private const uint8 SUPER_ENABLED_VALUE = 0x03;

	private GameBoyType? _game_boy_type;
	public GameBoyType game_boy_type {
		get {
			if (_game_boy_type != null)
				return _game_boy_type;

			FileInputStream stream;
			try {
				stream = file.read ();
			}
			catch (Error e) {
				_game_boy_type = GameBoyType.INVALID;

				return _game_boy_type;
			}

			uint8 buffer[1];

			uint8 color_value = 0;
			try {
				stream.seek (COLOR_TYPE_OFFSET, SeekType.SET);
				stream.read (buffer);
			}
			catch (Error e) {
				_game_boy_type = GameBoyType.INVALID;

				return _game_boy_type;
			}
			color_value = buffer[0];

			uint8 super_value = 0;
			try {
				stream.seek (SUPER_TYPE_OFFSET, SeekType.SET);
				stream.read (buffer);
			}
			catch (Error e) {
				_game_boy_type = GameBoyType.INVALID;

				return _game_boy_type;
			}
			super_value = buffer[0];

			switch (color_value) {
			case COLOR_ONLY_VALUE:
				if (super_value == SUPER_DISABLED_VALUE)
					_game_boy_type = GameBoyType.COLOR_ONLY;

				break;

			case COLOR_ENABLED_VALUE:
				if (super_value == SUPER_ENABLED_VALUE)
					_game_boy_type = GameBoyType.SUPER_COLOR_ENABLED;

				if (super_value == SUPER_DISABLED_VALUE)
					_game_boy_type = GameBoyType.COLOR_ENABLED;

				break;

			default:
				if (super_value == SUPER_ENABLED_VALUE)
					_game_boy_type = GameBoyType.SUPER_ENABLED;

				if (super_value == SUPER_DISABLED_VALUE)
					_game_boy_type = GameBoyType.CLASSIC;

				break;
			}

			return _game_boy_type;
		}
	}

	private File file;

	public GameBoyHeader (File file) {
		this.file = file;
	}

	public bool is_classic () {
		switch (game_boy_type) {
		case GameBoyType.SUPER_ENABLED:
		case GameBoyType.CLASSIC:
			return true;
		default:
			return false;
		}
	}

	public bool is_color () {
		switch (game_boy_type) {
		case GameBoyType.SUPER_COLOR_ENABLED:
		case GameBoyType.COLOR_ENABLED:
		case GameBoyType.COLOR_ONLY:
			return true;
		default:
			return false;
		}
	}
}

private enum Games.GameBoyType {
	INVALID,
	CLASSIC,
	SUPER_ENABLED,
	COLOR_ENABLED,
	SUPER_COLOR_ENABLED,
	COLOR_ONLY,
}

errordomain Games.GameBoyError {
	INVALID_HEADER,
}
