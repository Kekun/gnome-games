// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-mappings-manager.h")]
private class Games.GamepadMappingsManager : GLib.Object {
	public static GamepadMappingsManager get_instance ();
	public string? get_mapping (string guid);
	public string? get_default_mapping (string guid);
	public string? get_user_mapping (string guid);
	public void save_mapping (string guid, string name, string mapping_string);
	public void delete_mapping (string guid);
}