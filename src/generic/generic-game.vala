// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericGame : Object, Game {
	private string _name;
	public string name {
		get {
			try {
				_name = game_title.get_title ();
			}
			catch (Error e) {
				warning (e.message);
			}

			if (_name == null)
				_name = "";

			return _name;
		}
	}

	private Title game_title;
	private Icon game_icon;
	private Cover game_cover;
	private Runner game_runner;

	public GenericGame (Title title, Icon icon, Cover cover, Runner runner) {
		game_title = title;
		game_icon = icon;
		game_cover = cover;
		game_runner = runner;
	}

	public Icon get_icon () {
		return game_icon;
	}

	public Cover get_cover () {
		return game_cover;
	}

	public Runner get_runner () throws Error {
		return game_runner;
	}
}
