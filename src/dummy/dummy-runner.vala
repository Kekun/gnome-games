// This file is part of GNOME Games. License: GPLv3

private class Games.DummyRunner : Object, Runner {
	public bool can_resume {
		get { return false; }
	}

	public Gtk.Widget get_display () {
		return new DummyDisplay ();
	}

	public void start () throws RunError {
	}

	public void resume () throws RunError {
	}

	public void pause () {
	}
}
