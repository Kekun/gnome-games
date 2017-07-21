// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/gamepad-tester.ui")]
private class Games.GamepadTester : Gtk.Box {
	[GtkChild]
	private GamepadView gamepad_view;

	private Gamepad gamepad;

	private ulong gamepad_button_press_event_handler_id;
	private ulong gamepad_button_release_event_handler_id;
	private ulong gamepad_axis_event_handler_id;
	private ulong gamepad_hat_event_handler_id;

	public GamepadTester (Gamepad gamepad, GamepadViewConfiguration configuration) {
		this.gamepad = gamepad;
		try {
			gamepad_view.set_configuration (configuration);
		}
		catch (Error e) {
			critical ("Could not set up gamepad view: %s", e.message);
		}
	}

	public void start () {
		gamepad_view.reset ();
		connect_to_gamepad ();
	}

	public void stop () {
		disconnect_from_gamepad ();
	}

	private void connect_to_gamepad () {
		gamepad_button_press_event_handler_id = gamepad.button_press_event.connect ((event) => {
			on_button_event (event.gamepad_button, true);
		});
		gamepad_button_release_event_handler_id = gamepad.button_release_event.connect ((event) => {
			on_button_event (event.gamepad_button, false);
		});
		gamepad_axis_event_handler_id = gamepad.axis_event.connect ((event) => {
			on_axis_event (event.gamepad_axis);
		});
		gamepad_hat_event_handler_id = gamepad.hat_event.connect ((event) => {
			on_hat_event (event.gamepad_hat);
		});
	}

	private void disconnect_from_gamepad () {
		if (gamepad_button_press_event_handler_id != 0) {
			gamepad.disconnect (gamepad_button_press_event_handler_id);
			gamepad_button_press_event_handler_id = 0;
		}
		if (gamepad_button_release_event_handler_id != 0) {
			gamepad.disconnect (gamepad_button_release_event_handler_id);
			gamepad_button_release_event_handler_id = 0;
		}
		if (gamepad_axis_event_handler_id != 0) {
			gamepad.disconnect (gamepad_axis_event_handler_id);
			gamepad_axis_event_handler_id = 0;
		}
		if (gamepad_hat_event_handler_id != 0) {
			gamepad.disconnect (gamepad_hat_event_handler_id);
			gamepad_axis_event_handler_id = 0;
		}
	}

	private void on_button_event (EventGamepadButton event, bool pressed) {
		var highlight = pressed;
		gamepad_view.highlight ({ EventCode.EV_KEY, event.button }, highlight);
	}

	private void on_axis_event (EventGamepadAxis event) {
		var highlight = !(-0.8 < event.gamepad_axis.value < 0.8);
		gamepad_view.highlight ({ EventCode.EV_ABS, event.axis }, highlight);
	}

	private void on_hat_event (EventGamepadHat event) {
		var highlight = !(event.gamepad_hat.value == 0);
		gamepad_view.highlight ({ EventCode.EV_ABS, event.axis }, highlight);
	}
}
