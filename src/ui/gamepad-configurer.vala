// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/gamepad-configurer.ui")]
private class Games.GamepadConfigurer : Gtk.Box {
	private const GamepadInput[] STANDARD_GAMEPAD_INPUTS = {
		{ EventCode.EV_KEY, EventCode.BTN_A },
		{ EventCode.EV_KEY, EventCode.BTN_B },
		{ EventCode.EV_KEY, EventCode.BTN_X },
		{ EventCode.EV_KEY, EventCode.BTN_Y },
		{ EventCode.EV_KEY, EventCode.BTN_START },
		{ EventCode.EV_KEY, EventCode.BTN_MODE },
		{ EventCode.EV_KEY, EventCode.BTN_SELECT },
		{ EventCode.EV_KEY, EventCode.BTN_THUMBL },
		{ EventCode.EV_KEY, EventCode.BTN_THUMBR },
		{ EventCode.EV_KEY, EventCode.BTN_TL },
		{ EventCode.EV_KEY, EventCode.BTN_TR },
		{ EventCode.EV_KEY, EventCode.BTN_DPAD_UP },
		{ EventCode.EV_KEY, EventCode.BTN_DPAD_LEFT },
		{ EventCode.EV_KEY, EventCode.BTN_DPAD_DOWN },
		{ EventCode.EV_KEY, EventCode.BTN_DPAD_RIGHT },
		{ EventCode.EV_ABS, EventCode.ABS_X },
		{ EventCode.EV_ABS, EventCode.ABS_Y },
		{ EventCode.EV_ABS, EventCode.ABS_RX },
		{ EventCode.EV_ABS, EventCode.ABS_RY },
		{ EventCode.EV_KEY, EventCode.BTN_TL2 },
		{ EventCode.EV_KEY, EventCode.BTN_TR2 },
	};

	private const GamepadInputPath[] STANDARD_GAMEPAD_INPUT_PATHS = {
		{ { EventCode.EV_ABS, EventCode.ABS_X }, "leftx" },
		{ { EventCode.EV_ABS, EventCode.ABS_Y }, "lefty" },
		{ { EventCode.EV_ABS, EventCode.ABS_RX }, "rightx" },
		{ { EventCode.EV_ABS, EventCode.ABS_RY }, "righty" },
		{ { EventCode.EV_KEY, EventCode.BTN_A }, "a" },
		{ { EventCode.EV_KEY, EventCode.BTN_B }, "b" },
		{ { EventCode.EV_KEY, EventCode.BTN_DPAD_DOWN }, "dpdown" },
		{ { EventCode.EV_KEY, EventCode.BTN_DPAD_LEFT }, "dpleft" },
		{ { EventCode.EV_KEY, EventCode.BTN_DPAD_RIGHT }, "dpright" },
		{ { EventCode.EV_KEY, EventCode.BTN_DPAD_UP }, "dpup" },
		{ { EventCode.EV_KEY, EventCode.BTN_MODE }, "guide" },
		{ { EventCode.EV_KEY, EventCode.BTN_SELECT }, "back" },
		{ { EventCode.EV_KEY, EventCode.BTN_TL }, "leftshoulder" },
		{ { EventCode.EV_KEY, EventCode.BTN_TR }, "rightshoulder" },
		{ { EventCode.EV_KEY, EventCode.BTN_START }, "start" },
		{ { EventCode.EV_KEY, EventCode.BTN_THUMBL }, "leftstick" },
		{ { EventCode.EV_KEY, EventCode.BTN_THUMBR }, "rightstick" },
		{ { EventCode.EV_KEY, EventCode.BTN_TL2 }, "lefttrigger" },
		{ { EventCode.EV_KEY, EventCode.BTN_TR2 }, "righttrigger" },
		{ { EventCode.EV_KEY, EventCode.BTN_Y }, "x" },
		{ { EventCode.EV_KEY, EventCode.BTN_X }, "y" },
	};

	private const GamepadViewConfiguration STANDARD_GAMEPAD_VIEW_CONFIGURATION = {
		"resource:///org/gnome/Games/gamepads/standard-gamepad.svg", STANDARD_GAMEPAD_INPUT_PATHS
	};

	private enum State {
		TEST,
		CONFIGURE,
	}

	public signal void back ();

	private State _state;
	private State state {
		set {
			_state = value;
			immersive_mode = (state == State.CONFIGURE);

			switch (value) {
			case State.TEST:
				var user_mapping = mappings_manager.get_user_mapping (gamepad.guid);
				reset_button.set_sensitive (user_mapping != null);

				back_button.show ();
				cancel_button.hide ();
				action_bar.show ();
				/* translators: testing a gamepad, %s is its name */
				header_bar.title = _("Testing %s").printf (gamepad.name);
				header_bar.get_style_context ().remove_class ("selection-mode");
				stack.set_visible_child_name ("gamepad_tester");

				tester.start ();
				mapper.stop ();
				mapper.finished.disconnect (on_mapper_finished);

				break;
			case State.CONFIGURE:
				back_button.hide ();
				cancel_button.show ();
				action_bar.hide ();
				/* translators: configuring a gamepad, %s is its name */
				header_bar.title = _("Configuring %s").printf (gamepad.name);
				header_bar.get_style_context ().add_class ("selection-mode");
				stack.set_visible_child_name ("gamepad_mapper");

				tester.stop ();
				mapper.start ();
				mapper.finished.connect (on_mapper_finished);

				break;
			}
		}
		get { return _state; }
	}

	[GtkChild (name = "header_bar")]
	private Gtk.HeaderBar _header_bar;
	public Gtk.HeaderBar header_bar {
		private set {}
		get { return _header_bar; }
	}

	public bool immersive_mode { private set; get; }

	[GtkChild]
	private Gtk.Stack stack;
	[GtkChild]
	private Gtk.Box gamepad_mapper_holder;
	[GtkChild]
	private Gtk.Box gamepad_tester_holder;
	[GtkChild]
	private Gtk.ActionBar action_bar;
	[GtkChild]
	private Gtk.Button reset_button;
	[GtkChild]
	private Gtk.Button back_button;
	[GtkChild]
	private Gtk.Button cancel_button;

	private Gamepad gamepad;
	private GamepadMapper mapper;
	private GamepadTester tester;
	private GamepadMappingsManager mappings_manager;

	construct {
		mappings_manager = GamepadMappingsManager.get_instance ();
	}

	public GamepadConfigurer (Gamepad gamepad) {
		this.gamepad = gamepad;
		mapper = new GamepadMapper (gamepad, STANDARD_GAMEPAD_VIEW_CONFIGURATION, STANDARD_GAMEPAD_INPUTS);
		gamepad_mapper_holder.pack_start (mapper);
		tester = new GamepadTester (gamepad, STANDARD_GAMEPAD_VIEW_CONFIGURATION);
		gamepad_tester_holder.pack_start (tester);

		state = State.TEST;
	}

	[GtkCallback]
	private void on_reset_clicked () {
		reset_mapping ();
	}

	[GtkCallback]
	private void on_configure_clicked () {
		state = State.CONFIGURE;
	}

	[GtkCallback]
	private void on_back_clicked () {
		back ();
	}

	[GtkCallback]
	private void on_cancel_clicked () {
		state = State.TEST;
	}

	private void reset_mapping () {
		var message_dialog = new ResetGamepadMappingDialog ();
		message_dialog.set_transient_for ((Gtk.Window) get_toplevel ());
		message_dialog.response.connect ((response) => {
			switch (response) {
				case Gtk.ResponseType.ACCEPT:
					mappings_manager.delete_mapping (gamepad.guid);
					var sdl_string = mappings_manager.get_default_mapping (gamepad.guid);
					set_gamepad_mapping (sdl_string);
					reset_button.set_sensitive (false);

					break;
				default:
					break;
			}

			message_dialog.destroy();
		});
		message_dialog.show ();
	}

	private void on_mapper_finished (string sdl_string) {
		mappings_manager.save_mapping (gamepad.guid, gamepad.name, sdl_string);
		set_gamepad_mapping (sdl_string);

		state = State.TEST;
	}

	private void set_gamepad_mapping (string? sdl_string) {
		if (sdl_string == null) {
			gamepad.set_mapping (null);

			return;
		}
		try {
			var mapping = new GamepadMapping.from_sdl_string (sdl_string);
			gamepad.set_mapping (mapping);
		}
		catch (Error e) {
			critical (e.message);
		}
	}
}
