// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "raw-gamepad.h")]
private interface Games.RawGamepad : GLib.Object {
	public abstract signal void event (Event event);
	public abstract signal void standard_button_event (StandardGamepadButton button, bool value);
	public abstract signal void button_event (int code, bool value);
	public abstract signal void standard_axis_event (StandardGamepadAxis axis, double value);
	public abstract signal void axis_event (int axis, double value);
	public abstract signal void dpad_event (int dpad, int axis, int value);
	public abstract signal void unplugged ();
	public abstract string guid { get; }
}
