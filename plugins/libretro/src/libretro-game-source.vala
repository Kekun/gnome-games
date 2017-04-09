// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroGameSource : Object, GameSource {
	private Game[] games;

	public async void each_game (GameCallback callback) {
		if (games == null)
			yield fetch_games ();

		foreach (var game in games) {
			callback (game);

			Idle.add (each_game.callback);
			yield;
		}
	}

	public async void fetch_games () {
		games = {};
		var modules = new Retro.ModuleQuery (true);
		foreach (var core_descriptor in modules) {
			try {
				if (core_descriptor.get_is_game ())
					games += game_for_core_descriptor (core_descriptor);
			}
			catch (Error e) {
				debug (e.message);
			}

			Idle.add (fetch_games.callback);
			yield;
		}
	}

	private static Game game_for_core_descriptor (Retro.CoreDescriptor core_descriptor) throws Error {
		var uid = new LibretroUid (core_descriptor);
		var title = new LibretroTitle (core_descriptor);
		var icon = new LibretroIcon (core_descriptor);
		var cover = new DummyCover ();
		var runner = new RetroRunner.for_core_descriptor (core_descriptor, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}
