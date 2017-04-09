// This file is part of GNOME Games. License: GPL-3.0+.

// FIXME Workaround the autotools working poorly with Vala.
#if ENABLE_LINUX_GAMEPADS
#if ENABLE_UDEV

private class Games.LinuxRawGamepadMonitor : Object, RawGamepadMonitor {
	private static LinuxRawGamepadMonitor instance;

	private GUdev.Client client;
	private HashTable<string, RawGamepad> raw_gamepads;

	private LinuxRawGamepadMonitor () {
		client = new GUdev.Client ({"input"});
		client.uevent.connect (handle_udev_client_callback);

		raw_gamepads = new HashTable<string, RawGamepad> (str_hash, str_equal);

		// Coldplug gamepads
		var initial_devices_list = client.query_by_subsystem ("input");
		foreach (var device in initial_devices_list) {
			if (device.get_device_file () == null)
				continue;

			if (!is_gamepad (device))
				continue;

			add_gamepad (device);
		}
	}

	public static LinuxRawGamepadMonitor get_instance () {
		if (instance == null)
			instance = new LinuxRawGamepadMonitor ();

		return instance;
	}

	public void foreach_gamepad (RawGamepadCallback callback) {
		raw_gamepads.foreach((identifier, raw_gamepad) => callback (raw_gamepad));
	}

	private void handle_udev_client_callback (string action, GUdev.Device device) {
		if (device.get_device_file () == null)
			return;

		if (!is_gamepad (device))
			return;

		switch (action) {
		case "add":
			var raw_gamepad = add_gamepad (device);
			if (raw_gamepad != null)
				gamepad_plugged (raw_gamepad);

			break;
		case "remove":
			var raw_gamepad = remove_gamepad (device);
			if (raw_gamepad != null)
				// This signal is emitted from here to simplify the code
				raw_gamepad.unplugged ();

			break;
		}
	}

	private RawGamepad? add_gamepad (GUdev.Device device) {
		var identifier = device.get_device_file ();
		RawGamepad raw_gamepad;
		try {
			raw_gamepad = new LinuxRawGamepad (identifier);
		}
		catch (FileError e) {
			return null;
		}

		if (raw_gamepads.contains (identifier))
			return null;

		raw_gamepads[identifier] = raw_gamepad;

		return raw_gamepad;
	}

	private RawGamepad? remove_gamepad (GUdev.Device device) {
		var identifier = device.get_device_file ();
		if (!raw_gamepads.contains (identifier))
			return null;

		var raw_gamepad = raw_gamepads[identifier];
		raw_gamepads.remove (identifier);

		return raw_gamepad;
	}

	private static bool is_gamepad (GUdev.Device device) {
		return ((device.has_property ("ID_INPUT_JOYSTICK") && device.get_property ("ID_INPUT_JOYSTICK") == "1") ||
		        (device.has_property (".INPUT_CLASS") && device.get_property (".INPUT_CLASS") == "joystick"));
	}
}

#endif
#endif
