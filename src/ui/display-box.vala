// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/display-box.ui")]
private class Games.DisplayBox : Gtk.EventBox {
	private const uint INACTIVITY_TIME_MILLISECONDS = 2000;

	public signal void back ();

	public bool is_fullscreen { set; get; }

	public DisplayHeaderBar header_bar {
		get { return fullscreen_header_bar; }
	}

	private Runner _runner;
	public Runner runner {
		set {
			stack.visible_child = display_bin;

			_runner = value;
			remove_display ();

			if (runner == null)
				return;

			var display = runner.get_display ();
			set_display (display);
		}
		get { return _runner; }
	}

	[GtkChild]
	private Gtk.Overlay overlay;
	[GtkChild]
	private Gtk.Stack stack;
	[GtkChild]
	private ErrorDisplay error_display;
	[GtkChild]
	private Gtk.EventBox display_bin;
	[GtkChild]
	private Gtk.Revealer fullscreen_header_bar_revealer;
	[GtkChild]
	private DisplayHeaderBar fullscreen_header_bar;
	private Binding visible_binding;
	private Binding fullscreen_binding;

	private long timeout_id;

	construct {
		visible_binding = bind_property ("is-fullscreen", fullscreen_header_bar_revealer, "visible",
		                                 BindingFlags.BIDIRECTIONAL);
		fullscreen_binding = bind_property ("is-fullscreen", fullscreen_header_bar, "is-fullscreen",
		                                 BindingFlags.BIDIRECTIONAL);
		timeout_id = -1;
	}

	public void display_running_game_failed (Game game, string error_message) {
		stack.visible_child = error_display;
		error_display.running_game_failed (game, error_message);
	}

	[GtkCallback]
	private void on_fullscreen_changed () {
		if (is_fullscreen)
			on_activity ();
		else
			on_restore ();
	}

	[GtkCallback]
	private void on_fullscreen_header_bar_back () {
		back ();
	}

	[GtkCallback]
	private bool on_motion_event (Gdk.EventMotion event) {
		on_activity ();

		return false;
	}

	private void on_activity () {
		if (timeout_id != -1) {
			Source.remove ((uint) timeout_id);
			timeout_id = -1;
		}

		if (!is_fullscreen)
			return;

		timeout_id = Timeout.add (INACTIVITY_TIME_MILLISECONDS, on_inactivity);
		fullscreen_header_bar_revealer.reveal_child = true;
		show_cursor (true);
	}

	private bool on_inactivity () {
		timeout_id = -1;

		if (!is_fullscreen)
			return false;

		fullscreen_header_bar_revealer.reveal_child = false;
		show_cursor (false);
		overlay.grab_focus ();

		return false;
	}

	private void on_restore () {
		if (timeout_id != -1) {
			Source.remove ((uint) timeout_id);
			timeout_id = -1;
		}

		fullscreen_header_bar_revealer.reveal_child = false;
		show_cursor (true);
	}

	private void show_cursor (bool show) {
		var window = get_window ();
		if (window == null)
			return;

		if ((show && window.cursor == null) ||
		    (!show && window.cursor != null))
			return;

		// FIXME Gdk.Cursor.new() is deprecated but I didn't manage to make
		// Gdk.Cursor.from_display().
		window.cursor = show ? null : new Gdk.Cursor (Gdk.CursorType.BLANK_CURSOR);
	}

	private void set_display (Gtk.Widget display) {
		remove_display ();
		display_bin.add (display);
		display.visible = true;
	}

	private void remove_display () {
		var child = display_bin.get_child ();
		if (child != null)
			display_bin.remove (child);
	}
}
