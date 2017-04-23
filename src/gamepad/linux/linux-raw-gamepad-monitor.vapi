// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "linux-raw-gamepad-monitor.h")]
private class Games.LinuxRawGamepadMonitor : GLib.Object, RawGamepadMonitor {
	public static LinuxRawGamepadMonitor get_instance ();
}
