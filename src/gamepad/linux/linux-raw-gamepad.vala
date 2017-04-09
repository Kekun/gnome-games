// This file is part of GNOME Games. License: GPL-3.0+.

// FIXME Workaround the autotools working poorly with Vala.
#if ENABLE_LINUX_GAMEPADS

// FIXME This should be in LinuxRawGamepad but a bug in valac prevent us from using it in 'requires' statements.
const int GUID_LENGTH = 8;

private class Games.LinuxRawGamepad : Object, RawGamepad {
	private int fd;
	private uint? event_source_id;
	private Libevdev.Evdev device;

	private uint8 key_map[Linux.Input.KEY_MAX];
	private uint8 abs_map[Linux.Input.ABS_MAX];
	private Linux.Input.AbsInfo abs_info[Linux.Input.ABS_MAX];

	private string _guid;
	public string guid {
		get {
			if (_guid == null) {
				uint16 guid_array[GUID_LENGTH];
				guid_array[0] = (uint16) device.id_bustype.to_little_endian ();
				guid_array[1] = 0;
				guid_array[2] = (uint16) device.id_vendor.to_little_endian ();
				guid_array[3] = 0;
				guid_array[4] = (uint16) device.id_product.to_little_endian ();
				guid_array[5] = 0;
				guid_array[6] = (uint16) device.id_version.to_little_endian ();
				guid_array[7] = 0;
				_guid = uint16s_to_hex_string (guid_array);
			}

			return _guid;
		}
	}

	public LinuxRawGamepad (string file_name) throws FileError {
		fd = Posix.open (file_name, Posix.O_RDONLY | Posix.O_NONBLOCK);

		if (fd < 0)
			throw new FileError.FAILED (_("Unable to open file “%s”: %s"), file_name, Posix.strerror (Posix.errno));

		device = new Libevdev.Evdev ();
		if (device.set_fd (fd) < 0)
			throw new FileError.FAILED (_("Evdev is unable to open “%s”: %s"), file_name, Posix.strerror (Posix.errno));

		if (!is_joystick ())
			throw new FileError.NXIO ("“%s” is not a joystick", file_name);

		// Poll the events in the default main loop
		var channel = new IOChannel.unix_new (fd);
		event_source_id = channel.add_watch (IOCondition.IN, poll_events);

		// Initialize dpads, buttons and axes
		var buttons_number = 0;
		for (var i = Linux.Input.BTN_JOYSTICK; i < Linux.Input.KEY_MAX; i++) {
			if (device.has_event_code (Linux.Input.EV_KEY, i)) {
				key_map[i - Linux.Input.BTN_MISC] = buttons_number;
				buttons_number++;
			}
		}
		for (var i = Linux.Input.BTN_MISC; i < Linux.Input.BTN_JOYSTICK; i++) {
			if (device.has_event_code (Linux.Input.EV_KEY, i)) {
				key_map[i - Linux.Input.BTN_MISC] = buttons_number;
				buttons_number++;
			}
		}


		// Get info about axes
		var axes_number = 0;
		for (var i = 0; i < Linux.Input.ABS_MAX; i++) {
			// Skip dpads
			if (i == Linux.Input.ABS_HAT0X) {
				i = Linux.Input.ABS_HAT3Y;

				continue;
			}
			if (device.has_event_code (Linux.Input.EV_ABS, i)) {
				var absinfo = device.get_abs_info (i);
				abs_map[i] = axes_number;
				abs_info[axes_number] = absinfo;
				axes_number++;
			}
		}
	}

	~LinuxRawGamepad () {
		Posix.close (fd);
		remove_event_source ();
	}

	private bool poll_events () {
		while (device.has_event_pending () > 0)
			handle_evdev_event ();

		return true;
	}

	private bool has_key (uint code) {
		return device.has_event_code (Linux.Input.EV_KEY, code);
	}

	private bool has_abs (uint code) {
		return device.has_event_code (Linux.Input.EV_ABS, code);
	}

	private bool is_joystick () {
		/* Same detection code as udev-builtin-input_id.c in systemd
		 * joysticks don’t necessarily have buttons; e. g.
		 * rudders/pedals are joystick-like, but buttonless; they have
		 * other fancy axes */
		bool has_joystick_axes_or_buttons = has_key (Linux.Input.BTN_TRIGGER) ||
			has_key (Linux.Input.BTN_A) ||
			has_key (Linux.Input.BTN_1) ||
			has_abs (Linux.Input.ABS_RX) ||
			has_abs (Linux.Input.ABS_RY) ||
			has_abs (Linux.Input.ABS_RZ) ||
			has_abs (Linux.Input.ABS_THROTTLE) ||
			has_abs (Linux.Input.ABS_RUDDER) ||
			has_abs (Linux.Input.ABS_WHEEL) ||
			has_abs (Linux.Input.ABS_GAS) ||
			has_abs (Linux.Input.ABS_BRAKE);
		return has_joystick_axes_or_buttons;
	}

	private void handle_evdev_event () {
		Linux.Input.Event event;
		if (device.next_event (Libevdev.ReadFlag.NORMAL, out event) != 0)
			return;

		// We need to typecast this to int as the Linux Input API VAPI presents them as ints
		// while libevdev represents them as uints
		int code = event.code;
		switch (event.type) {
		case Linux.Input.EV_KEY:
			if ((code & Linux.Input.BTN_GAMEPAD) == Linux.Input.BTN_GAMEPAD)
				standard_button_event (button_to_standard_button (code), (bool) event.value);
			button_event (key_map[code - Linux.Input.BTN_MISC], (bool) event.value);

			break;
		case Linux.Input.EV_ABS:
			switch (code) {
			case Linux.Input.ABS_HAT0X:
			case Linux.Input.ABS_HAT0Y:
			case Linux.Input.ABS_HAT1X:
			case Linux.Input.ABS_HAT1Y:
			case Linux.Input.ABS_HAT2X:
			case Linux.Input.ABS_HAT2Y:
			case Linux.Input.ABS_HAT3X:
			case Linux.Input.ABS_HAT3Y:
				code -= Linux.Input.ABS_HAT0X;
				dpad_event (code / 2, code % 2, event.value);

				// We don’t want to send an axis event as dpad events
				// are handled differently by the gamepad objects, hence
				// we return here.
				return;
			case Linux.Input.ABS_X:
			case Linux.Input.ABS_Y:
			case Linux.Input.ABS_RX:
			case Linux.Input.ABS_RY:
				var standard_axis = axis_to_standard_axis (code);
				var axis = abs_map[code];
				var value = centered_axis_value (abs_info[axis], event.value);
				standard_axis_event (standard_axis, value);

				break;
			}

			var axis = abs_map[code];
			var value = centered_axis_value (abs_info[axis], event.value);
			axis_event (axis, value);

			break;
		}
	}

	private void remove_event_source () {
		if (event_source_id == null)
			return;

		Source.remove (event_source_id);
		event_source_id = null;
	}

	private string uint16s_to_hex_string (uint16[] data)
				   requires (data.length == GUID_LENGTH)
	{
		const string hex_to_ascii_map = "0123456789abcdef";

		var builder = new StringBuilder ();
		foreach (uint16 el in data) {
			uint8 c = (uint8) el;
			builder.append_unichar (hex_to_ascii_map[c >> 4]);
			builder.append_unichar (hex_to_ascii_map[c & 0x0F]);

			c = (uint8) (el >> 8);
			builder.append_unichar (hex_to_ascii_map[c >> 4]);
			builder.append_unichar (hex_to_ascii_map[c & 0x0F]);
		}

		return builder.str;
	}

	private StandardGamepadButton button_to_standard_button (int code) {
		switch (code) {
		case Linux.Input.BTN_A:
			return StandardGamepadButton.A;
		case Linux.Input.BTN_B:
			return StandardGamepadButton.B;
		case Linux.Input.BTN_X:
			return StandardGamepadButton.Y;
		case Linux.Input.BTN_Y:
			return StandardGamepadButton.X;
		case Linux.Input.BTN_TL:
			return StandardGamepadButton.SHOULDER_L;
		case Linux.Input.BTN_TR:
			return StandardGamepadButton.SHOULDER_R;
		case Linux.Input.BTN_TL2:
			return StandardGamepadButton.TRIGGER_L;
		case Linux.Input.BTN_TR2:
			return StandardGamepadButton.TRIGGER_R;
		case Linux.Input.BTN_SELECT:
			return StandardGamepadButton.SELECT;
		case Linux.Input.BTN_START:
			return StandardGamepadButton.START;
		case Linux.Input.BTN_MODE:
			return StandardGamepadButton.HOME;
		case Linux.Input.BTN_THUMBL:
			return StandardGamepadButton.STICK_L;
		case Linux.Input.BTN_THUMBR:
			return StandardGamepadButton.STICK_R;
		default:
			return StandardGamepadButton.UNKNOWN;
		}
	}

	private StandardGamepadAxis axis_to_standard_axis (int code) {
		switch (code) {
		case Linux.Input.ABS_X:
			return StandardGamepadAxis.LEFT_X;
		case Linux.Input.ABS_Y:
			return StandardGamepadAxis.LEFT_Y;
		case Linux.Input.ABS_RX:
			return StandardGamepadAxis.RIGHT_X;
		case Linux.Input.ABS_RY:
			return StandardGamepadAxis.RIGHT_Y;
		default:
			return StandardGamepadAxis.UNKNOWN;
		}
	}

	private static double centered_axis_value (Linux.Input.AbsInfo abs_info, int32 value) {
		var min_absolute = ((int64) abs_info.minimum).abs ();

		var max_normalized = ((int64) abs_info.maximum) + min_absolute;
		var value_normalized = ((int64) value) + min_absolute;

		var max_centered = max_normalized / 2;
		var value_centered = value_normalized - max_normalized + max_centered;

		var divisor = value_centered < 0 ? max_centered + 1 : max_centered;

		return (double) value_centered / (double) divisor;
	}
}

#endif
