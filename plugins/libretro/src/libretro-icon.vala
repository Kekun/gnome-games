// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroIcon : Object, Icon {
	private Retro.CoreDescriptor core_descriptor;

	public LibretroIcon (Retro.CoreDescriptor core_descriptor) {
		this.core_descriptor = core_descriptor;
	}

	public GLib.Icon? get_icon () {
		try {
			if (!core_descriptor.has_icon ())
				return null;

			return core_descriptor.get_icon ();
		}
		catch (Error e) {
			debug (e.message);

			return null;
		}
	}
}
