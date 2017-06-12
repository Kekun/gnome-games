// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-dpad.h")]
private struct Games.GamepadDPad {
	Games.GamepadInput inputs[4];
	int32 axis_values[2];
}
