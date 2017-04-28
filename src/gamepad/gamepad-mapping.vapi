// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-mapping.h")]
private class Games.GamepadMapping : GLib.Object {
	public GamepadMapping.from_sdl_string (string? mapping_string) throws GamepadMappingError;
	public GamepadMappedEvent get_dpad_mapping (int dpad_index, int dpad_axis, int dpad_value);
	public GamepadMappedEvent get_axis_mapping (int axis_number);
	public GamepadMappedEvent get_button_mapping (int button_number);
}
