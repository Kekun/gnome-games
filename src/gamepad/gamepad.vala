// This file is part of GNOME Games. License: GPL-3.0+.

/**
 * This class represents a gamepad
 *
 * The client interfaces with this class primarily
 */
private class Games.Gamepad : Object {

	/**
	 * Emitted when a button is pressed/released
	 * @param  button        The button pressed
	 * @param  value         True if pressed, False if released
	 */
	public signal void button_event (StandardGamepadButton button, bool value);

	/**
	 * Emitted when an axis's value changes
	 * @param  axis          The axis number from 0 to axes_number
	 * @param  value         The value of the axis ranging from -1 to 1
	 */
	public signal void axis_event (StandardGamepadAxis axis, double value);

	/**
	 * Emitted when the gamepad is unplugged
	 */
	public signal void unplugged ();

	private RawGamepad raw_gamepad;
	private GamepadMapping? mapping;

	public Gamepad (RawGamepad raw_gamepad) throws GamepadMappingError {
		this.raw_gamepad = raw_gamepad;
		var guid = raw_gamepad.guid;
		var mappings_manager = GamepadMappingsManager.get_instance ();
		try {
			mapping = new GamepadMapping.from_sdl_string (mappings_manager.get_mapping (guid));
		}
		catch (Error e) {
			debug (e.message);
		}
		raw_gamepad.standard_button_event.connect (on_standard_button_event);
		raw_gamepad.button_event.connect (on_raw_button_event);
		raw_gamepad.standard_axis_event.connect (on_standard_axis_event);
		raw_gamepad.axis_event.connect (on_raw_axis_event);
		raw_gamepad.dpad_event.connect (on_raw_dpad_event);
		raw_gamepad.unplugged.connect (() => unplugged ());
	}

	private void on_standard_button_event (StandardGamepadButton button, bool value) {
		if (mapping != null)
			return;

		button_event (button, value);
	}

	private void on_raw_button_event (int button, bool value) {
		if (mapping == null)
			return;

		var event = mapping.get_button_mapping (button);
		switch (event.type) {
		case GamepadInputType.AXIS:
			axis_event (event.axis, value ? 1 : 0);

			break;
		case GamepadInputType.BUTTON:
			button_event (event.button, value);

			break;
		}
	}

	private void on_standard_axis_event (StandardGamepadAxis axis, double value) {
		if (mapping != null)
			return;

		axis_event (axis, value);
	}

	private void on_raw_axis_event (int axis, double value) {
		if (mapping == null)
			return;

		var event = mapping.get_axis_mapping (axis);
		switch (event.type) {
		case GamepadInputType.AXIS:
			axis_event (event.axis, value);

			break;
		case GamepadInputType.BUTTON:
			button_event (event.button, value > 0);

			break;
		}
	}

	private void on_raw_dpad_event (int dpad_index, int axis, int value) {
		if (mapping == null) {
			if (dpad_index != 0)
				return;

			if (axis == 0) {
				button_event (StandardGamepadButton.DPAD_LEFT, value < 0);
				button_event (StandardGamepadButton.DPAD_RIGHT, value > 0);
			}
			else if (axis == 1) {
				button_event (StandardGamepadButton.DPAD_UP, value < 0);
				button_event (StandardGamepadButton.DPAD_DOWN, value > 0);
			}

			return;
		}

		var event = mapping.get_dpad_mapping (dpad_index, axis, value);
		switch (event.type) {
		case GamepadInputType.AXIS:
			axis_event (event.axis, value.abs ());

			break;
		case GamepadInputType.BUTTON:
			button_event (event.button, (bool) value.abs ());

			break;
		}
	}
}
