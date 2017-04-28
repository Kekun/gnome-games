// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-dpad.h")]
private struct Games.GamepadDPad {
	GamepadInputType types[4];
	int values[4];
	int axis_values[2];
}
