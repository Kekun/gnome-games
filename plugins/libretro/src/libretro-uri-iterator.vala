// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroUriIterator : Object, UriIterator {
	private Retro.ModuleIterator iterator;
	private Uri? uri;

	construct {
		var modules = new Retro.ModuleQuery (true);
		iterator = modules.iterator ();
		uri = null;
	}

	public new Uri? get () {
		return uri;
	}

	public bool next () {
		while (iterator.next ()) {
			var core_descriptor = iterator.get ();
			try {
				if (!core_descriptor.get_is_game ())
					continue;
			}
			catch (Error e) {
				debug (e.message);

				continue;
			}

			var string_uri = core_descriptor.get_uri ();
			uri = new Uri (@"libretro+$string_uri");

			return true;
		}

		uri = null;

		return false;
	}
}
