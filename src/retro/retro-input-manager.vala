// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroInputManager : Retro.InputDeviceManager, Retro.Rumble {
	private Retro.VirtualGamepad keyboard;
	private GamepadMonitor gamepad_monitor;
	private Retro.InputDevice?[] input_devices;
	private int keyboard_port;
	private bool present_analog_sticks;

	public RetroInputManager (Gtk.Widget widget, bool present_analog_sticks) {
		this.present_analog_sticks = present_analog_sticks;

		keyboard = new Retro.VirtualGamepad (widget);
		set_keyboard (widget);

		gamepad_monitor = GamepadMonitor.get_instance ();
		gamepad_monitor.foreach_gamepad ((gamepad) => {
			var port = input_devices.length;
			var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
			input_devices += retro_gamepad;
			set_controller_device (port, retro_gamepad);
			gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		});

		keyboard_port = input_devices.length;
		input_devices += keyboard;
		set_controller_device (keyboard_port, keyboard);
		gamepad_monitor.gamepad_plugged.connect (handle_gamepad_plugged);
	}

	private void handle_gamepad_plugged (Gamepad gamepad) {
		// Plug this gamepad to the port where the keyboard was plugged as a last resort
		var port = keyboard_port;
		var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
		input_devices[port] = retro_gamepad;
		set_controller_device (port, retro_gamepad);
		gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));

		// Assign keyboard to another unplugged port if exists and return
		for (var i = keyboard_port; i < input_devices.length; i++) {
			if (input_devices[i] == null) {
				// Found an unplugged port and so assigning keyboard to it
				keyboard_port = i;
				input_devices[keyboard_port] = keyboard;
				set_controller_device (keyboard_port, keyboard);

				return;
			}
		}

		// Now it means that there is no unplugged port so append keyboard to ports
		keyboard_port = input_devices.length;
		input_devices += keyboard;
		set_controller_device (keyboard_port, keyboard);
	}

	private void handle_gamepad_unplugged (int port) {
		if (keyboard_port > port) {
			// Remove the controller and shift keyboard to "lesser" port
			input_devices[keyboard_port] = null;
			remove_controller_device (keyboard_port);
			keyboard_port = port;
			input_devices[keyboard_port] = keyboard;
			set_controller_device (keyboard_port, keyboard);
		}
		else {
			// Just remove the controller as no need to shift keyboard
			input_devices[port] = null;
			remove_controller_device (port);
		}
	}

	private bool set_rumble_state (uint port, Retro.RumbleEffect effect, uint16 strength) {
		if (port > input_devices.length)
			return false;

		if (input_devices[port] == null || input_devices[port] == keyboard)
			return false;

		// TODO Transmit the rumble signal to the gamepad.

		return false;
	}
}
