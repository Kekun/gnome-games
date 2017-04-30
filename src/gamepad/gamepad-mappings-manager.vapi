// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-mappings-manager.h")]
private class Games.GamepadMappingsManager : GLib.Object {
	public static GamepadMappingsManager get_instance ();
	public string? get_mapping (string guid);
}
