// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroUid : Object, Uid {
	private Retro.CoreDescriptor core_descriptor;

	public LibretroUid (Retro.CoreDescriptor core_descriptor) {
		this.core_descriptor = core_descriptor;
	}

	public string get_uid () throws Error {
		var id = core_descriptor.get_id ();

		return @"libretro-$id";
	}
}
