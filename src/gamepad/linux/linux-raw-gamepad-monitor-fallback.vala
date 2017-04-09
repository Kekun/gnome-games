// This file is part of GNOME Games. License: GPL-3.0+.

// FIXME Workaround the autotools working poorly with Vala.
#if ENABLE_LINUX_GAMEPADS
#if !ENABLE_UDEV
private class Games.LinuxRawGamepadMonitor : Object, RawGamepadMonitor {
	private static LinuxRawGamepadMonitor instance;

	private HashTable<string, RawGamepad> raw_gamepads;

	private LinuxRawGamepadMonitor () {
		raw_gamepads = new HashTable<string, RawGamepad> (str_hash, str_equal);

		// Coldplug gamepads
		try {
			string directory = "/dev/input";
			Dir dir = Dir.open (directory, 0);
			string? name = null;
			while ((name = dir.read_name ()) != null) {
				string path = Path.build_filename (directory, name);
				RawGamepad raw_gamepad;
				try {
					raw_gamepad = new LinuxRawGamepad (path);
				}
				catch (FileError e) {
					if (!(e is FileError.NXIO))
						debug ("Failed to open gamepad %s: %s\n", path, e.message);

					continue;
				}

				raw_gamepads[name] = raw_gamepad;
				gamepad_plugged (raw_gamepad);
			}
		} catch (FileError err) {
			debug (err.message);
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
}

#endif
#endif
