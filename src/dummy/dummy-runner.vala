// This file is part of GNOME Games. License: GPLv3

private class Games.DummyRunner : Object, Runner {
	public bool can_fullscreen {
		get { return false; }
	}

	public bool can_quit_safely {
		get { return true; }
	}

	public bool can_resume {
		get { return false; }
	}

	public MediaSet? media_set {
		get { return null; }
	}

	public void check_is_valid () throws Error {
	}

	public Gtk.Widget get_display () {
		return new DummyDisplay ();
	}

	public void start () throws Error {
	}

	public void resume () throws Error {
	}

	public void pause () {
	}

	public void stop () {
	}
}
