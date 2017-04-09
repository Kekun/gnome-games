// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroTitle : Object, Title {
	private Retro.CoreDescriptor core_descriptor;

	public LibretroTitle (Retro.CoreDescriptor core_descriptor) {
		this.core_descriptor = core_descriptor;
	}

	public string get_title () throws Error {
		return core_descriptor.get_name ();
	}
}
