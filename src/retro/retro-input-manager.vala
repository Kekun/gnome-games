// This file is part of GNOME Games. License: GPLv3

private class Games.RetroInputManager : Object {
	public RetroGtk.InputDeviceManager input { get; private set; }

	private RetroGtk.VirtualGamepad keyboard;
	private GamepadMonitor gamepad_monitor;
	private bool[] is_port_plugged;
	private int keyboard_port;

	public RetroInputManager (Gtk.Widget widget) {
		input = new RetroGtk.InputDeviceManager ();
		keyboard = new RetroGtk.VirtualGamepad (widget);
		gamepad_monitor = GamepadMonitor.get_instance ();

		input.set_keyboard (new RetroGtk.Keyboard (widget));

		gamepad_monitor.foreach_gamepad ((gamepad) => {
			var port = is_port_plugged.length;
			is_port_plugged += true;
			input.set_controller_device (port, new RetroGamepad (gamepad));
			gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		});

		keyboard_port = is_port_plugged.length;
		is_port_plugged += true;
		input.set_controller_device (keyboard_port, keyboard);
		gamepad_monitor.gamepad_plugged.connect (handle_gamepad_plugged);
	}

	private void handle_gamepad_plugged (Gamepad gamepad) {
		// Plug this gamepad to the port where the keyboard was plugged as a last resort
		var port = keyboard_port;
		gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		input.set_controller_device (keyboard_port, new RetroGamepad (gamepad));

		// Assign keyboard to another unplugged port if exists and return
		for (var i = keyboard_port; i < is_port_plugged.length; i++) {
			if (!is_port_plugged[i]) {
				// Found an unplugged port and so assigning keyboard to it
				keyboard_port = i;
				is_port_plugged[keyboard_port] = true;
				input.set_controller_device (keyboard_port, keyboard);

				return;
			}
		}

		// Now it means that there is no unplugged port so append keyboard to ports
		keyboard_port = is_port_plugged.length;
		is_port_plugged += true;
		input.set_controller_device (keyboard_port, keyboard);
	}

	private void handle_gamepad_unplugged (int port) {
		if (keyboard_port > port) {
			// Remove the controller and shift keyboard to "lesser" port
			is_port_plugged[keyboard_port] = false;
			input.remove_controller_device (keyboard_port);
			keyboard_port = port;
			input.set_controller_device (keyboard_port, keyboard);
		}
		else {
			// Just remove the controller as no need to shift keyboard
			is_port_plugged[port] = false;
			input.remove_controller_device (port);
		}
	}
}
