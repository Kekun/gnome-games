// This file is part of GNOME Games. License: GPLv3

private class Games.DummyRunner : Object, Runner {
	public Gtk.Widget? get_display () {
		return new DummyDisplay ();
	}

	public void run () throws RunError {
	}
}
