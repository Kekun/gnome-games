// This file is part of GNOME Games. License: GPLv3

/**
 * This is one of the interfaces that needs to be implemented by the driver.
 *
 * This interface represents a gamepad and deals with handling events that are
 * emitted by a gamepad and also provide properties like name and guid along
 * with number of buttons, axes and dpads.
 */
private interface Games.RawGamepad : Object {
	/**
	 * Emitted when a button is pressed/released
	 * @param  code          The button code from 0 to buttons_number
	 * @param  value         True if pressed, False if released
	 */
	public abstract signal void button_event (int code, bool value);

	/**
	 * Emitted when an axis's value changes
	 * @param  axis          The axis number from 0 to axes_number
	 * @param  value         The value of the axis ranging from -1 to 1
	 */
	public abstract signal void axis_event (int axis, double value);

	/**
	 * Emitted when a dpad's axis's value changes
	 * @param  dpad          The dpad number from 0 to
	 * @param  axis          The axis: 0 for X, 1 for Y
	 * @param  value         The value of the axis ranging from -1 to 1
	 */
	public abstract signal void dpad_event (int dpad, int axis, int value);

	/**
	 * Emitted when the gamepad is unplugged
	 */
	public abstract signal void unplugged ();

	public abstract string guid { get; }
}
