// This file is part of GNOME Games. License: GPLv3

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

	private Icon? _icon;
	public Icon? icon {
		get {
			_icon = game_cover.get_cover ();

			return _icon;
		}
	}

	private Title game_title;
	private Cover game_cover;
	private Runner game_runner;

	public GenericGame (Title title, Cover cover, Runner runner) {
		game_title = title;
		game_cover = cover;
		game_runner = runner;
	}

	public Runner get_runner () throws Error {
		return game_runner;
	}
}
