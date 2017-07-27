// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-monitor.h")]
private class Games.GamepadMonitor : GLib.Object {
	public signal void gamepad_plugged (Gamepad gamepad);
	public signal void gamepad_unplugged ();
	public static GamepadMonitor get_instance ();
	public void foreach_gamepad (GamepadCallback callback);
}

[CCode (cheader_filename = "gamepad-monitor.h")]
private delegate void Games.GamepadCallback (Games.Gamepad gamepad);
