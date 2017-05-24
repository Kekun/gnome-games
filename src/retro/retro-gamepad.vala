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
		buttons = new bool[EventCode.KEY_MAX + 1];
		axes = new int16[EventCode.ABS_MAX + 1];

		gamepad.button_press_event.connect ((event) => buttons[event.gamepad_button.button] = true);
		gamepad.button_release_event.connect ((event) => buttons[event.gamepad_button.button] = false);
		gamepad.axis_event.connect ((event) => axes[event.gamepad_axis.axis] = (int16) (event.gamepad_axis.value * int16.MAX));
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
			return buttons[EventCode.BTN_A];
		case Retro.JoypadId.Y:
			return buttons[EventCode.BTN_Y];
		case Retro.JoypadId.SELECT:
			return buttons[EventCode.BTN_SELECT];
		case Retro.JoypadId.START:
			return buttons[EventCode.BTN_START];
		case Retro.JoypadId.UP:
			return buttons[EventCode.BTN_DPAD_UP];
		case Retro.JoypadId.DOWN:
			return buttons[EventCode.BTN_DPAD_DOWN];
		case Retro.JoypadId.LEFT:
			return buttons[EventCode.BTN_DPAD_LEFT];
		case Retro.JoypadId.RIGHT:
			return buttons[EventCode.BTN_DPAD_RIGHT];
		case Retro.JoypadId.A:
			return buttons[EventCode.BTN_B];
		case Retro.JoypadId.X:
			return buttons[EventCode.BTN_X];
		case Retro.JoypadId.L:
			return buttons[EventCode.BTN_TL];
		case Retro.JoypadId.R:
			return buttons[EventCode.BTN_TR];
		case Retro.JoypadId.L2:
			return buttons[EventCode.BTN_TL2];
		case Retro.JoypadId.R2:
			return buttons[EventCode.BTN_TR2];
		case Retro.JoypadId.L3:
			return buttons[EventCode.BTN_THUMBL];
		case Retro.JoypadId.R3:
			return buttons[EventCode.BTN_THUMBR];
		default:
			return false;
		}
	}

	public int16 get_analog_value (Retro.AnalogIndex index, Retro.AnalogId id) {
		switch (index) {
		case Retro.AnalogIndex.LEFT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[EventCode.ABS_X];
			case Retro.AnalogId.Y:
				return axes[EventCode.ABS_Y];
			default:
				return 0;
			}
		case Retro.AnalogIndex.RIGHT:
			switch (id) {
			case Retro.AnalogId.X:
				return axes[EventCode.ABS_RX];
			case Retro.AnalogId.Y:
				return axes[EventCode.ABS_RY];
			default:
				return 0;
			}
		default:
			return 0;
		}
	}
}
