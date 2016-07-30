// This file is part of GNOME Games. License: GPLv3

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

	[GtkCallback]
	private void on_fullscreen_changed () {
		on_activity ();
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
		if (timeout_id != -1)
			Source.remove ((uint) timeout_id);

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
		overlay.add (display);
		display.visible = true;
	}

	private void remove_display () {
		var child = overlay.get_child ();
		if (child != null)
			overlay.remove (child);
	}
}
