// This file is part of GNOME Games. License: GPLv3

public class Games.LibretroGameSource : Object, GameSource {
	private Retro.CoreDescriptor[] descriptors;

	public async void each_game (GameCallback callback) {
		if (descriptors == null) {
			descriptors = {};
			// TODO Should yield for each core descriptor.
			Retro.ModuleQuery.foreach_core_descriptor (parse_core_descriptor);
		}

		foreach (var core_descriptor in descriptors) {
			var game = game_for_core_descriptor (core_descriptor);
			callback (game);
			yield;
		}
	}

	private bool parse_core_descriptor (Retro.CoreDescriptor core_descriptor) {
		try {
			if (core_descriptor.get_is_game ())
				descriptors += core_descriptor;
		}
		catch (Error e) {
			debug (e.message);
		}

		return false;
	}

	private static Game game_for_core_descriptor (Retro.CoreDescriptor core_descriptor) throws Error {
		var uid = new LibretroUid (core_descriptor);
		var title = new LibretroTitle (core_descriptor);
		var icon = new LibretroIcon (core_descriptor);
		var cover = new DummyCover ();
		var runner = new RetroRunner.for_core_descriptor (core_descriptor, uid);

		return new GenericGame (title, icon, cover, runner);
	}
}
