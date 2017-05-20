// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "raw-gamepad.h")]
private interface Games.RawGamepad : GLib.Object {
	public abstract signal void event (Event event);
	public abstract signal void unplugged ();
	public abstract string guid { get; }
	public abstract string name { get; }
}
