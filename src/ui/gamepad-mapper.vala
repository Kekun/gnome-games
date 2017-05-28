// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/gamepad-mapper.ui")]
private class Games.GamepadMapper : Gtk.Box {
	public signal void finished (string sdl_string);

	[GtkChild]
	private GamepadView gamepad_view;
	[GtkChild]
	private Gtk.Label info_message;

	private Gamepad gamepad;
	private GamepadMappingBuilder mapping_builder;
	private GamepadInput[] mapping_inputs;
	private GamepadInput input;
	private uint current_input_index;

	private ulong gamepad_event_handler_id;

	public GamepadMapper (Gamepad gamepad, GamepadViewConfiguration configuration, GamepadInput[] mapping_inputs) {
		this.gamepad = gamepad;
		this.mapping_inputs = mapping_inputs;
		try {
			gamepad_view.set_configuration (configuration);
		}
		catch (Error e) {
			critical ("Could not set up gamepad view: %s", e.message);
		}
	}

	public void start () {
		mapping_builder = new GamepadMappingBuilder ();
		current_input_index = 0;
		connect_to_gamepad ();

		next_input ();
	}

	public void stop () {
		disconnect_from_gamepad ();
	}

	[GtkCallback]
	private void on_skip_clicked () {
		next_input ();
	}

	private void connect_to_gamepad () {
		gamepad_event_handler_id = gamepad.event.connect ((event) => {
			switch (event.type) {
			case EventType.EVENT_GAMEPAD_BUTTON_RELEASE:
				on_button_event (event.gamepad_button);

				break;
			case EventType.EVENT_GAMEPAD_AXIS:
				on_axis_event (event.gamepad_axis);

				break;
			case EventType.EVENT_GAMEPAD_HAT:
				on_hat_event (event.gamepad_hat);

				break;
			default:
				break;
			}
		});
	}

	private void disconnect_from_gamepad () {
		if (gamepad_event_handler_id != 0) {
			gamepad.disconnect (gamepad_event_handler_id);
			gamepad_event_handler_id = 0;
		}
	}

	private void on_button_event (EventGamepadButton event) {
		if (input.type == EventCode.EV_ABS)
			return;

		var success = mapping_builder.set_button_mapping (event.gamepad_button.hardware_index,
		                                                  input);
		if (!success)
			return;

		next_input ();
	}

	private void on_axis_event (EventGamepadAxis event) {
		if (input.type == EventCode.EV_KEY)
			return;

		if (-0.8 < event.gamepad_axis.value < 0.8)
			return;

		var success = mapping_builder.set_axis_mapping (event.gamepad_axis.hardware_index,
		                                                input);
		if (!success)
			return;

		next_input ();
	}

	private void on_hat_event (EventGamepadHat event) {
		if (event.gamepad_hat.value == 0)
			return;

		var success = mapping_builder.set_hat_mapping (event.gamepad_hat.hardware_index,
		                                               event.gamepad_hat.value,
		                                               input);
		if (!success)
			return;

		next_input ();
	}

	private void next_input () {
		if (current_input_index == mapping_inputs.length) {
			var sdl_string = mapping_builder.build_sdl_string ();
			finished (sdl_string);

			return;
		}

		gamepad_view.reset ();
		input = mapping_inputs[current_input_index++];
		gamepad_view.highlight (input, true);

		update_info_message ();
	}

	private void update_info_message () {
		switch (input.type) {
		case EventCode.EV_KEY:
			info_message.label = _("Press suitable button on your gamepad");

			break;
		case EventCode.EV_ABS:
			if (input.code == EventCode.ABS_X || input.code == EventCode.ABS_RX)
				info_message.label = _("Move suitable axis left/right on your gamepad");
			else if (input.code == EventCode.ABS_Y || input.code == EventCode.ABS_RY)
				info_message.label = _("Move suitable axis up/down on your gamepad");

			break;
		default:
			break;
		}
	}
}
