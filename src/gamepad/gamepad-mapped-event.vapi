// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "gamepad-mapped-event.h")]
private struct Games.GamepadMappedEvent {
	GamepadInputType type;
	StandardGamepadAxis axis;
	StandardGamepadButton button;
}
