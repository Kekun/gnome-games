// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroGamepad: Object, Retro.InputDevice {
	public Gamepad gamepad { get; construct; }
	public bool present_analog_sticks { get; construct; }

	private bool[] buttons;
	private int16[] axes;

	public RetroGamepad (Gamepad gamepad, bool present_analog_sticks) {
		Object (gamepad: gamepad, present_analog_sticks: present_analog_sticks);
	}

	construct {
		buttons = new bool[StandardGamepadButton.HOME + 1];
		axes = new int16[4];

		gamepad.button_event.connect ((button, value) => buttons[button] = value);
		gamepad.axis_event.connect ((axis, value) => axes[axis] = (int16) (value * int16.MAX));
	}

	public void poll () {}

	public int16 get_input_state (Retro.DeviceType device, uint index, uint id) {
		switch (device) {
		case Retro.DeviceType.JOYPAD:
			return get_button_pressed ((Retro.JoypadId) id) ? int16.MAX : 0;
		case Retro.DeviceType.ANALOG:
			return get_analog_value ((Retro.AnalogIndex) index, (Retro.AnalogId) id);
		default:
			return 0;
		}
	}

	public Retro.DeviceType get_device_type () {
		if (present_analog_sticks)
			return Retro.DeviceType.ANALOG;

		return Retro.DeviceType.JOYPAD;
	}

	public uint64 get_device_capabilities () {
		return (1 << Retro.DeviceType.JOYPAD) | (1 << Retro.DeviceType.ANALOG);
	}

	public bool get_button_pressed (Retro.JoypadId button) {
		switch (button) {
		case Retro.JoypadId.B:
			return buttons[StandardGamepadButton.A];
		case Retro.JoypadId.Y:
			return buttons[StandardGamepadButton.X];
		case Retro.JoypadId.SELECT:
			return buttons[StandardGamepadButton.SELECT];
		case Retro.JoypadId.START:
			return buttons[StandardGamepadButton.START];
		case Retro.JoypadId.UP:
			return buttons[StandardGamepadButton.DPAD_UP];
		case Retro.JoypadId.DOWN:
			return buttons[StandardGamepadButton.DPAD_DOWN];
		case Retro.JoypadId.LEFT:
			return buttons[StandardGamepadButton.DPAD_LEFT];
		case Retro.JoypadId.RIGHT:
			return buttons[StandardGamepadButton.DPAD_RIGHT];
		case Retro.JoypadId.A:
			return buttons[StandardGamepadButton.B];
		case Retro.JoypadId.X:
			return buttons[StandardGamepadButton.Y];
		case Retro.JoypadId.L:
			return buttons[StandardGamepadButton.SHOULDER_L];
		case Retro.JoypadId.R:
			return buttons[StandardGamepadButton.SHOULDER_R];
		case Retro.JoypadId.L2:
			return buttons[StandardGamepadButton.TRIGGER_L];
		case Retro.JoypadId.R2:
			return buttons[StandardGamepadButton.TRIGGER_R];
		case Retro.JoypadId.L3:
			return buttons[StandardGamepadButton.STICK_L];
		case Retro.JoypadId.R3:
			return buttons[StandardGamepadButton.STICK_R];
		default:
			return false;
		}
	}

	public int16 get_analog_value (Retro.AnalogIndex index, Retro.AnalogId id) {
		switch (index) {
		case Retro.AnalogIndex.LEFT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[StandardGamepadAxis.LEFT_X];
			case Retro.AnalogId.Y:
				return axes[StandardGamepadAxis.LEFT_Y];
			default:
				return 0;
			}
		case Retro.AnalogIndex.RIGHT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[StandardGamepadAxis.RIGHT_X];
			case Retro.AnalogId.Y:
				return axes[StandardGamepadAxis.RIGHT_Y];
			default:
				return 0;
			}
		default:
			return 0;
		}
	}
}
