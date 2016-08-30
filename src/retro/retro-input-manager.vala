// This file is part of GNOME Games. License: GPLv3

private class Games.RetroInputManager : RetroGtk.InputDeviceManager, Retro.Rumble {
	private RetroGtk.VirtualGamepad keyboard;
	private GamepadMonitor gamepad_monitor;
	private bool[] is_port_plugged;
	private Gamepad?[] gamepads;
	private int keyboard_port;
	private bool present_analog_sticks;

	public RetroInputManager (Gtk.Widget widget, bool present_analog_sticks) {
		this.present_analog_sticks = present_analog_sticks;

		keyboard = new RetroGtk.VirtualGamepad (widget);
		gamepad_monitor = GamepadMonitor.get_instance ();

		set_keyboard (new RetroGtk.Keyboard (widget));

		gamepad_monitor.foreach_gamepad ((gamepad) => {
			var port = is_port_plugged.length;
			is_port_plugged += true;
			gamepads += gamepad;
			set_controller_device (port, new RetroGamepad (gamepad, present_analog_sticks));
			gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		});

		keyboard_port = is_port_plugged.length;
		is_port_plugged += true;
		gamepads += null;
		set_controller_device (keyboard_port, keyboard);
		gamepad_monitor.gamepad_plugged.connect (handle_gamepad_plugged);
	}

	private void handle_gamepad_plugged (Gamepad gamepad) {
		// Plug this gamepad to the port where the keyboard was plugged as a last resort
		var port = keyboard_port;
		gamepad.unplugged.connect (() => handle_gamepad_unplugged (port));
		set_controller_device (keyboard_port, new RetroGamepad (gamepad, present_analog_sticks));
		gamepads[port] = gamepad;

		// Assign keyboard to another unplugged port if exists and return
		for (var i = keyboard_port; i < is_port_plugged.length; i++) {
			if (!is_port_plugged[i]) {
				// Found an unplugged port and so assigning keyboard to it
				keyboard_port = i;
				is_port_plugged[keyboard_port] = true;
				gamepads[keyboard_port] = null;
				set_controller_device (keyboard_port, keyboard);

				return;
			}
		}

		// Now it means that there is no unplugged port so append keyboard to ports
		keyboard_port = is_port_plugged.length;
		is_port_plugged += true;
		set_controller_device (keyboard_port, keyboard);
	}

	private void handle_gamepad_unplugged (int port) {
		if (keyboard_port > port) {
			// Remove the controller and shift keyboard to "lesser" port
			is_port_plugged[keyboard_port] = false;
			gamepads[keyboard_port] = null;
			remove_controller_device (keyboard_port);
			keyboard_port = port;
			gamepads[keyboard_port] = null;
			set_controller_device (keyboard_port, keyboard);
		}
		else {
			// Just remove the controller as no need to shift keyboard
			is_port_plugged[port] = false;
			gamepads[port] = null;
			remove_controller_device (port);
		}
	}

	private bool set_rumble_state (uint port, Retro.RumbleEffect effect, uint16 strength) {
		if (port > gamepads.length)
			return false;

		if (gamepads[port] == null)
			return false;

		// TODO Transmit the rumble signal to the gamepad.

		return false;
	}
}
