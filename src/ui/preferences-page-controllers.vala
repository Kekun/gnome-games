// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-page-controllers.ui")]
private class Games.PreferencesPageControllers: Gtk.Stack, PreferencesPage {
	public Gtk.HeaderBar header_bar { protected set; get; }
	public bool immersive_mode { protected set; get; }

	[GtkChild]
	private Gtk.ListBox gamepads_list_box;
	[GtkChild]
	private Gtk.Box extra_stack_child_holder;
	[GtkChild]
	private Gtk.HeaderBar default_header_bar;

	private GamepadMonitor gamepad_monitor;

	private Binding header_bar_binding;
	private Binding immersive_mode_binding;
	private ulong back_handler_id;

	construct {
		header_bar = default_header_bar;
		immersive_mode = false;

		gamepad_monitor = GamepadMonitor.get_instance ();
		gamepad_monitor.gamepad_unplugged.connect (rebuild_gamepad_list);
		gamepad_monitor.gamepad_plugged.connect (rebuild_gamepad_list);
		build_gamepad_list ();
	}

	public void visible_page_changed () {
		on_back (null);
	}

	private void rebuild_gamepad_list () {
		clear_gamepad_list ();
		build_gamepad_list ();
	}

	private void build_gamepad_list () {
		var i = 0;
		gamepad_monitor.foreach_gamepad ((gamepad) => {
			i += 1;
			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
			box.pack_start (new Gtk.Label (gamepad.name), false, false);
			box.margin = 6;
			box.show_all ();
			gamepads_list_box.add (box);
		});
	}

	private void clear_gamepad_list () {
		gamepads_list_box.foreach ((child) => child.destroy ());
	}

	[GtkCallback]
	private void gamepads_list_box_row_activated (Gtk.ListBoxRow row_item) {
		Gamepad? gamepad = null;
		var i = 0;
		var row_index = row_item.get_index ();
		gamepad_monitor.foreach_gamepad ((gamepad_) => {
			if (i++ == row_index)
				gamepad = gamepad_;
		});

		if (gamepad == null)
			return;
		var configurer = new GamepadConfigurer(gamepad);
		back_handler_id = configurer.back.connect (on_back);
		header_bar_binding = configurer.bind_property ("header-bar", this, "header-bar",
		                                               BindingFlags.SYNC_CREATE);
		immersive_mode_binding = configurer.bind_property ("immersive-mode", this, "immersive-mode",
		                                                   BindingFlags.SYNC_CREATE);
		extra_stack_child_holder.pack_start (configurer);
		set_visible_child_name ("extra_stack_child");
	}

	private void on_back (Object? emitter) {
		header_bar_binding = null;
		immersive_mode_binding = null;
		if (back_handler_id != 0) {
			if (emitter != null)
				emitter.disconnect (back_handler_id);
			back_handler_id = 0;
		}

		header_bar = default_header_bar;
		immersive_mode = false;
		set_visible_child_name ("main_stack_child");
		extra_stack_child_holder.foreach ((child) => child.destroy ());
	}
}
