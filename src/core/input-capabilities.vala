// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.InputCapabilities : Object {
	public abstract bool get_allow_classic_gamepads () throws Error;
	public abstract bool get_allow_analog_gamepads () throws Error;
}
