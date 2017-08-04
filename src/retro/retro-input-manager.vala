// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroInputManager : Retro.InputDeviceManager, Retro.Rumble {
	private Retro.InputDevice core_view_joypad;
	private GamepadMonitor gamepad_monitor;
	private Retro.InputDevice?[] input_devices;
	private int core_view_joypad_port;
	private bool present_analog_sticks;

	public RetroInputManager (Retro.CoreView view, bool present_analog_sticks) {
		this.present_analog_sticks = present_analog_sticks;

		core_view_joypad = view.as_input_device (Retro.DeviceType.JOYPAD);
		set_keyboard (view);

		gamepad_monitor = GamepadMonitor.get_instance ();
		gamepad_monitor.foreach_gamepad ((gamepad) => {
			var port = input_devices.length;
			var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
			input_devices += retro_gamepad;
			set_controller_device (port, retro_gamepad);
			gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		});

		core_view_joypad_port = input_devices.length;
		input_devices += core_view_joypad;
		set_controller_device (core_view_joypad_port, core_view_joypad);
		gamepad_monitor.gamepad_plugged.connect (handle_gamepad_plugged);
	}

	private void handle_gamepad_plugged (Gamepad gamepad) {
		// Plug this gamepad to the port where the CoreView's joypad was
		// plugged as a last resort.
		var port = core_view_joypad_port;
		var retro_gamepad = new RetroGamepad (gamepad, present_analog_sticks);
		input_devices[port] = retro_gamepad;
		set_controller_device (port, retro_gamepad);
		gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));

		// Assign the CoreView's joypad to another unplugged port if it
		// exists and return.
		for (var i = core_view_joypad_port; i < input_devices.length; i++) {
			if (input_devices[i] == null) {
				// Found an unplugged port and so assigning core_view_joypad to it
				core_view_joypad_port = i;
				input_devices[core_view_joypad_port] = core_view_joypad;
				set_controller_device (core_view_joypad_port, core_view_joypad);

				return;
			}
		}

		// Now it means that there is no unplugged port so append the
		// CoreView's joypad to ports.
		core_view_joypad_port = input_devices.length;
		input_devices += core_view_joypad;
		set_controller_device (core_view_joypad_port, core_view_joypad);
	}

	private void handle_gamepad_unplugged (int port) {
		if (core_view_joypad_port > port) {
			// Remove the controller and shift the CoreView's joypad to
			// "lesser" port.
			input_devices[core_view_joypad_port] = null;
			remove_controller_device (core_view_joypad_port);
			core_view_joypad_port = port;
			input_devices[core_view_joypad_port] = core_view_joypad;
			set_controller_device (core_view_joypad_port, core_view_joypad);
		}
		else {
			// Just remove the controller as no need to shift the
			// CoreView's joypad.
			input_devices[port] = null;
			remove_controller_device (port);
		}
	}

	private bool set_rumble_state (uint port, Retro.RumbleEffect effect, uint16 strength) {
		if (port > input_devices.length)
			return false;

		if (input_devices[port] == null || input_devices[port] == core_view_joypad)
			return false;

		// TODO Transmit the rumble signal to the gamepad.

		return false;
	}
}
