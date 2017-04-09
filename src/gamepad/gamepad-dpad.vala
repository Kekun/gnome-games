// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GamepadDPad : Object {
	public GamepadInputType types[4];
	public int values[4];
	public int axis_values[2];

	public GamepadDPad () {
		axis_values[0] = axis_values[1] = 0;
		types[0] = types[1] = types[2] = types[3] = GamepadInputType.INVALID;
	}
}
