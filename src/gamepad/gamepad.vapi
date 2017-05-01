// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad.h")]
private class Games.Gamepad : GLib.Object {
	public signal void button_event (StandardGamepadButton button, bool value);
	public signal void axis_event (StandardGamepadAxis axis, double value);
	public signal void unplugged ();
	public Gamepad (RawGamepad raw_gamepad) throws Error;
}
