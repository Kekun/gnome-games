// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GamepadMapping : Object {
	private GamepadInputType[] buttons_type;
	private int[] buttons_value;
	private GamepadInputType[] axes_type;
	private int[] axes_value;
	private GamepadDPad[] dpads;

	public GamepadMapping.from_sdl_string (string? mapping_string) throws GamepadMappingError {
		if (mapping_string == null)
			throw new GamepadMappingError.NOT_A_MAPPING (_("The mapping string can’t be null."));

		if (mapping_string == "")
			throw new GamepadMappingError.NOT_A_MAPPING (_("The mapping string can’t be empty."));

		var mappings = mapping_string.split (",");
		foreach (var mapping in mappings) {
			var splitted_mapping = mapping.split (":");
			if (splitted_mapping.length != 2)
				continue;

			var mapping_key = mapping.split (":")[0];
			var mapping_value = mapping.split (":")[1];
			var type = parse_input_type (mapping_key);
			if (type == GamepadInputType.INVALID) {
				if (mapping_key != "platform")
					debug ("Invalid token : %s", mapping_key);

				continue;
			}
			int parsed_key;
			switch (type) {
			case GamepadInputType.BUTTON:
				parsed_key = parse_button (mapping_key);

				break;
			case GamepadInputType.AXIS:
				parsed_key = parse_axis (mapping_key);

				break;
			default:
				continue;
			}

			switch (mapping_value[0]) {
			case 'h':
				parse_dpad_value (mapping_value, type, parsed_key);

				break;
			case 'b':
				parse_button_value (mapping_value, type, parsed_key);

				break;
			case 'a':
				parse_axis_value (mapping_value, type, parsed_key);

				break;
			}
		}
	}

	public GamepadMappedEvent get_dpad_mapping (int dpad_index, int dpad_axis, int dpad_value) {
		var event = GamepadMappedEvent ();
		var dpad = dpads[dpad_index];
		var dpad_changed_value = dpad_value == 0 ? dpad.axis_values[dpad_axis] : dpad_value;
		// We add 4 so that the remainder is always positive.
		int dpad_position = (dpad_changed_value + dpad_axis + 4) % 4;
		dpad.axis_values[dpad_axis] = dpad_value;
		event.type = dpad.types[dpad_position];
		switch (event.type) {
		case GamepadInputType.AXIS:
			event.axis = (StandardGamepadAxis) dpad.values[dpad_position];

			break;
		case GamepadInputType.BUTTON:
			event.button = (StandardGamepadButton) dpad.values[dpad_position];

			break;
		}

		return event;
	}

	public GamepadMappedEvent get_axis_mapping (int axis_number) {
		var event = GamepadMappedEvent ();
		event.type = axis_number < axes_type.length ? axes_type[axis_number] :
		                                              GamepadInputType.INVALID;
		switch (event.type) {
		case GamepadInputType.AXIS:
			event.axis = (StandardGamepadAxis) axes_value[axis_number];

			break;
		case GamepadInputType.BUTTON:
			event.button = (StandardGamepadButton) axes_value[axis_number];

			break;
		}

		return event;
	}

	public GamepadMappedEvent get_button_mapping (int button_number) {
		var event = GamepadMappedEvent ();
		event.type = button_number < buttons_type.length ? buttons_type[button_number] :
		                                                   GamepadInputType.INVALID;
		switch (event.type) {
		case GamepadInputType.AXIS:
			event.axis = (StandardGamepadAxis) buttons_value[button_number];

			break;
		case GamepadInputType.BUTTON:
			event.button = (StandardGamepadButton) buttons_value[button_number];

			break;
		}

		return event;
	}

	private void parse_dpad_value (string mapping_value, GamepadInputType type, int parsed_key) {
		var dpad_parse_array = mapping_value[1:mapping_value.length].split (".");
		var dpad_index = int.parse (dpad_parse_array[0]);
		var dpad_position_2pow = int.parse (dpad_parse_array[1]);
		int dpad_position = 0;
		while (dpad_position_2pow > 1) {
			dpad_position_2pow >>= 1;
			dpad_position++;
		}
		while (dpads.length <= dpad_index)
			dpads += new GamepadDPad ();
		dpads[dpad_index].types[dpad_position] = type;
		dpads[dpad_index].values[dpad_position] = parsed_key;
	}

	private void parse_button_value (string mapping_value, GamepadInputType type, int parsed_key) {
		var button = int.parse (mapping_value[1:mapping_value.length]);
		while (buttons_type.length <= button)
			buttons_type += GamepadInputType.INVALID;
		if (buttons_value.length <= button)
			buttons_value.resize (button + 1);
		buttons_type[button] = type;
		buttons_value[button] = parsed_key;
	}

	private void parse_axis_value (string mapping_value, GamepadInputType type, int parsed_key) {
		var axis = int.parse (mapping_value[1:mapping_value.length]);
		while (axes_type.length <= axis)
			axes_type += GamepadInputType.INVALID;
		if (axes_value.length <= axis)
			axes_value.resize (axis + 1);
		axes_type[axis] = type;
		axes_value[axis] = parsed_key;
	}

	public static GamepadInputType parse_input_type (string mapping_string) {
		switch (mapping_string) {
		case "leftx":
		case "lefty":
		case "rightx":
		case "righty":
			return GamepadInputType.AXIS;
		case "a":
		case "b":
		case "back":
		case "dpdown":
		case "dpleft":
		case "dpright":
		case "dpup":
		case "guide":
		case "leftshoulder":
		case "leftstick":
		case "lefttrigger":
		case "rightshoulder":
		case "rightstick":
		case "righttrigger":
		case "start":
		case "x":
		case "y":
			return GamepadInputType.BUTTON;
		default:
			return GamepadInputType.INVALID;
		}
	}

	public static StandardGamepadAxis parse_axis (string mapping_string) {
		switch (mapping_string) {
		case "leftx":
			return StandardGamepadAxis.LEFT_X;
		case "lefty":
			return StandardGamepadAxis.LEFT_Y;
		case "rightx":
			return StandardGamepadAxis.RIGHT_X;
		case "righty":
			return StandardGamepadAxis.RIGHT_Y;
		default:
			return StandardGamepadAxis.UNKNOWN;
		}
	}

	public static StandardGamepadButton parse_button (string mapping_string) {
		switch (mapping_string) {
		case "a":
			return StandardGamepadButton.A;
		case "b":
			return StandardGamepadButton.B;
		case "back":
			return StandardGamepadButton.SELECT;
		case "dpdown":
			return StandardGamepadButton.DPAD_DOWN;
		case "dpleft":
			return StandardGamepadButton.DPAD_LEFT;
		case "dpright":
			return StandardGamepadButton.DPAD_RIGHT;
		case "dpup":
			return StandardGamepadButton.DPAD_UP;
		case "guide":
			return StandardGamepadButton.HOME;
		case "leftshoulder":
			return StandardGamepadButton.SHOULDER_L;
		case "leftstick":
			return StandardGamepadButton.STICK_L;
		case "lefttrigger":
			return StandardGamepadButton.TRIGGER_L;
		case "rightshoulder":
			return StandardGamepadButton.SHOULDER_R;
		case "rightstick":
			return StandardGamepadButton.STICK_R;
		case "righttrigger":
			return StandardGamepadButton.TRIGGER_R;
		case "start":
			return StandardGamepadButton.START;
		case "x":
			return StandardGamepadButton.X;
		case "y":
			return StandardGamepadButton.Y;
		default:
			return StandardGamepadButton.UNKNOWN;
		}
	}
}
