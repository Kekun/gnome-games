// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad.h")]
private class Games.Gamepad : GLib.Object {
	public signal void event (Event event);
	public signal void button_press_event (Event event);
	public signal void button_release_event (Event event);
	public signal void axis_event (Event event);
	public signal void hat_event (Event event);
	public signal void unplugged ();
	public Gamepad (RawGamepad raw_gamepad);
	public string guid { get; }
	public string name { get; }
	public void set_mapping (GamepadMapping? mapping);
}
