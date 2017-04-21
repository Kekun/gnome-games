// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "linux-raw-gamepad.h")]
private class Games.LinuxRawGamepad : GLib.Object, RawGamepad {
	public LinuxRawGamepad (string file_name) throws GLib.FileError;
}
