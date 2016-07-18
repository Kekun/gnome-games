// This file is part of GNOME Games. License: GPLv3

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
			throw new FileError.FAILED (@"Unable to open file $file_name: $(Posix.strerror (Posix.errno))");

		device = new Libevdev.Evdev ();
		if (device.set_fd (fd) < 0)
			throw new FileError.FAILED (@"Evdev is unable to open $file_name: $(Posix.strerror (Posix.errno))");

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

	private void handle_evdev_event () {
		Linux.Input.Event event;
		if (device.next_event (Libevdev.ReadFlag.NORMAL, out event) != 0)
			return;

		// We need to typecast this to int as the Linux Input API VAPI presents them as ints
		// while libevdev represents them as uints
		int code = event.code;
		switch (event.type) {
		case Linux.Input.EV_KEY:
			if (code >= Linux.Input.BTN_MISC)
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

				break;
			default:
				var axis = abs_map[code];
				axis_event (axis, (double) event.value / abs_info[axis].maximum);

				break;
			}

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
}
