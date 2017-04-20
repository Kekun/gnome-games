// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "raw-gamepad-monitor.h")]
private interface Games.RawGamepadMonitor : GLib.Object {
	public abstract signal void gamepad_plugged (RawGamepad raw_gamepad);
	public abstract void foreach_gamepad (RawGamepadCallback callback);
}

[CCode (cheader_filename = "raw-gamepad-monitor.h")]
private delegate void Games.RawGamepadCallback (Games.RawGamepad raw_gamepad);
